#!/bin/bash

# Ensure the certs directory exists
mkdir -p certs

echo "Generating CA certificate..."

openssl req -x509 -newkey rsa:4096 -keyout certs/ca.key -out certs/ca.crt -days 365 -nodes -config scripts/openssl.cnf

# Check if CA certificate was generated successfully
if [[ ! -f certs/ca.crt ]]; then
  echo "❌ Failed to generate CA certificate. Exiting."
  exit 1
fi

# Generate certificates for each Elasticsearch node
for node in elasticsearch1 elasticsearch2 elasticsearch3; do
  echo "Generating certificate for $node..."

  # Use OpenSSL config instead of -subj
  cat > scripts/$node.cnf <<EOF
[ req ]
default_bits       = 4096
default_md         = sha256
distinguished_name = req_distinguished_name
prompt             = no

[ req_distinguished_name ]
C  = US
ST = California
L  = SanFrancisco
O  = MyCompany
OU = IT
CN = $node
EOF

  openssl req -newkey rsa:4096 -keyout certs/$node.key -out certs/$node.csr -nodes -config scripts/$node.cnf

  if [[ ! -f certs/$node.csr ]]; then
    echo "❌ Failed to generate CSR for $node. Skipping."
    continue
  fi

  openssl x509 -req -in certs/$node.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/$node.crt -days 365

  if [[ ! -f certs/$node.crt ]]; then
    echo "❌ Failed to generate certificate for $node."
  else
    echo "✅ Certificate for $node generated successfully."
  fi
done

echo "🎉 All certificates generated successfully!"
