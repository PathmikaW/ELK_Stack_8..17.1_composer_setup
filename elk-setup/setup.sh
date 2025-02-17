#!/bin/bash
echo "🚀 Starting ELK Setup Script..."

# Load Environment Variables
if [ ! -f ".env" ]; then
  echo "❌ ERROR: .env file not found. Please create it before running this script."
  exit 1
fi

set -o allexport
source .env 2>/dev/null || { echo "❌ ERROR: Failed to load .env file."; exit 1; }
set +o allexport

echo "DEBUG: ELASTIC_PASSWORD=${ELASTIC_PASSWORD}"
echo "DEBUG: KIBANA_SYSTEM_PASSWORD=${KIBANA_SYSTEM_PASSWORD}"

# Function to Check if a Service is Running
check_service_running() {
  SERVICE_NAME=$1
  if ! docker ps | grep -q "$SERVICE_NAME"; then
    echo "❌ ERROR: $SERVICE_NAME is not running. Exiting..."
    exit 1
  fi
}

# Stop Existing ELK Containers
echo "🛑 Stopping any existing ELK containers..."
docker-compose down -v || { echo "❌ ERROR: Failed to stop existing containers."; exit 1; }

# Generate SSL Certificates if Missing
if [ ! -f "certs/ca.crt" ]; then
  echo "🔐 SSL certificates missing. Generating new certificates..."
  chmod +x scripts/generate-certs.sh
  ./scripts/generate-certs.sh || { echo "❌ ERROR: Failed to generate SSL certificates."; exit 1; }
else
  echo "✅ SSL certificates already exist. Skipping generation."
fi

# Start Elasticsearch Nodes
echo "🚀 Starting Elasticsearch Cluster..."
docker-compose up -d elasticsearch1 elasticsearch2 elasticsearch3 || { echo "❌ ERROR: Failed to start Elasticsearch nodes."; exit 1; }

# Wait for Elasticsearch to be Reachable (Timeout 60 Seconds)
echo "⏳ Waiting for Elasticsearch Cluster to be ready (max 60s)..."
TIMEOUT=60
ELAPSED=0
while true; do
  # Check cluster health
  HEALTH_RESPONSE=$(curl -k -X GET "https://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=5s" -u "elastic:${ELASTIC_PASSWORD}")
  echo "DEBUG: Cluster Health Response: $HEALTH_RESPONSE"

  # Extract the status using grep and sed
  STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"status":"[^"]*"' | sed 's/"status":"\([^"]*\)"/\1/')
  if [ -z "$STATUS" ]; then
    STATUS="unknown"
  fi

  echo "DEBUG: Extracted Status: $STATUS"

  if [[ "$STATUS" == "yellow" || "$STATUS" == "green" ]]; then
    echo "✅ Elasticsearch Cluster status identified as '$STATUS'. Proceeding..."
    break
  else
    echo "⏳ Still waiting for Elasticsearch cluster... Current status: ${STATUS}"
  fi

  sleep 5
  ((ELAPSED+=5))
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "⚠️ WARNING: Elasticsearch is taking too long to form a cluster. Proceeding anyway..."
    break
  fi
done

# Ensure Elasticsearch is Running Before Proceeding
check_service_running "elasticsearch1"
echo "✅ Elasticsearch Cluster check completed!"

# Add a Short Delay to Ensure Elasticsearch is Fully Initialized
echo "⏳ Adding a 5-second delay to ensure Elasticsearch is fully initialized..."
sleep 5

# Set Kibana System Password from `.env`
echo "🔑 Setting password for kibana_system user..."
MAX_RETRIES=2
RETRY_COUNT=0
while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
  echo "DEBUG: Executing curl command:"
  echo "curl -k -X POST \"https://localhost:9200/_security/user/kibana_system/_password\" \\
    -H \"Content-Type: application/json\" \\
    -u \"elastic:${ELASTIC_PASSWORD}\" \\
    --insecure \\
    -d '{\"password\": \"${KIBANA_SYSTEM_PASSWORD}\"}'"

  RESPONSE=$(curl -k -X POST "https://localhost:9200/_security/user/kibana_system/_password" \
    -H "Content-Type: application/json" \
    -u "elastic:${ELASTIC_PASSWORD}" \
    --insecure \
    -d '{"password": "'"${KIBANA_SYSTEM_PASSWORD}"'"}')

  echo "DEBUG: Attempt $((RETRY_COUNT + 1)) - Response Code: $RESPONSE"

    if [ "$RESPONSE" == "{}" ]; then
    echo "✅ Password for kibana_system set successfully!"
    break
  else
    echo "⏳ Retrying to set kibana_system password... Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES"
    sleep 5
    ((RETRY_COUNT++))
  fi
done

if [ "$RETRY_COUNT" -eq "$MAX_RETRIES" ]; then
  echo "❌ ERROR: Failed to set Kibana system password after $MAX_RETRIES attempts."
  exit 1
fi

# Verify Kibana System Authentication
echo "🔍 Verifying kibana_system authentication..."
AUTH_RESPONSE=$(curl -k -s -X GET "https://localhost:9200/" -u "kibana_system:${KIBANA_SYSTEM_PASSWORD}")
echo "DEBUG: Response Body for kibana_system authentication: $AUTH_RESPONSE"

# Check if the response contains a valid Elasticsearch JSON response
if echo "$AUTH_RESPONSE" | grep -q '"cluster_name"'; then
  echo "✅ Kibana system authentication successful!"
else
  echo "❌ ERROR: Kibana system authentication failed. Response: $AUTH_RESPONSE"
  exit 1
fi

# Start Remaining ELK Services
echo "🚀 Starting Kibana, Logstash, and Filebeat..."
docker-compose up -d kibana logstash filebeat || { echo "❌ ERROR: Failed to start Kibana/Logstash/Filebeat."; exit 1; }
echo "🎉 ELK Stack Started Successfully!"