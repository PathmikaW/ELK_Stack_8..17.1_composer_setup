## **📊 ELK Stack 8.17.1 - Docker Compose Setup**
A **fully configured ELK stack (Elasticsearch, Logstash, Kibana, Filebeat)** setup with **SSL/TLS encryption**, **Kibana authentication**, and **multi-node Elasticsearch clustering**.

### **🚀 Features**
✅ **Multi-node Elasticsearch cluster** (3 nodes)  
✅ **Full security & SSL/TLS encryption** (Configurable via `.env`)  
✅ **Kibana, Logstash, and Filebeat integration**  
✅ **Automatic Kibana Service Token generation**  
✅ **Docker-optimized deployment with persistent volumes**  

---

## **📌 Prerequisites**
Before running this setup, ensure you have:
- **Docker & Docker Compose installed**
- **Git Bash or PowerShell (Admin) for running scripts**
- **WSL 2 backend enabled (for Windows users)**

---

## **🚀 1. Setup & Installation**
### **Step 1: Clone the Repository**
```sh
git clone https://github.com/PathmikaW/ELK_Stack_8..17.1_composer_setup.git
cd elk-docker-setup
```

### **Step 2: Configure Environment Variables**
Edit the `.env` file to set up your environment:
```ini
# Elasticsearch Cluster Configuration
CLUSTER_NAME=es-docker-cluster
ELASTIC_PASSWORD=changeme

# Kibana Service Token 
KIBANA_SERVICE_TOKEN=changeme


---

### **Step 3: Run the ELK Setup Script**
This script will **generate the Kibana token, configure SSL, and start the ELK stack**.
```sh
chmod +x setup.sh
./setup.sh
```

---

## **🚀 2. Start and Verify the ELK Stack**
Once the setup is complete, verify that all services are running:
```sh
docker ps
```
👉 **Expected Output:**
```
CONTAINER ID   IMAGE                                                STATUS         PORTS
abcd1234       docker.elastic.co/elasticsearch/elasticsearch:8.17.1   Up 2 minutes  9200/tcp
efgh5678       docker.elastic.co/kibana/kibana:8.17.1                 Up 2 minutes  5601/tcp
ijkl9012       docker.elastic.co/logstash/logstash:8.17.1             Up 2 minutes  5044/tcp
mnop3456       docker.elastic.co/beats/filebeat:8.17.1                Up 2 minutes  
```

### **📊 Access Kibana Dashboard**
1. Open your browser and navigate to **`https://localhost:5601`**
2. **Login using:**
   - **Username:** `elastic`
   - **Password:** `changeme`

---

## **⚡ Common Issues & Fixes**
### **🛠️ Issue: `vm.max_map_count` Too Low (Bootstrap Check Failed)**
Elasticsearch requires `vm.max_map_count` to be `262144`. Run:
```sh
sysctl -w vm.max_map_count=262144
```
To make it persistent:
```sh
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
```

### **🛠️ Issue: Kibana Token Expired**
If Kibana fails to authenticate, **rerun** the setup script:
```sh
./scripts/setup.sh
```

### **🛠️ Issue: `security_exception` - Unable to authenticate Kibana System**
#### **Fix: Reset the Kibana System Password**
```sh
curl -k -X POST "https://localhost:9200/_security/user/kibana_system/_password" \
-H "Content-Type: application/json" \
-u elastic:changeme --insecure \
-d '{"password": "Kibana@98"}'
```

---

## **🚀 3. Stop & Restart ELK Stack**
### **Stop Everything Without Deleting Data:**
```sh
docker-compose down
```

### **Restart Everything:**
```sh
docker-compose up -d
```

🚨 **WARNING:** If you run:
```sh
docker-compose down -v
```
🚨 **This will DELETE all Elasticsearch data, requiring you to reset security and regenerate the Kibana token!**

---

## **📌 ELK Service Verification Commands**
Use these commands to **verify your ELK services are working correctly**.

| ✅ Command | ✅ What It Checks |
|-----------|------------------|
| `curl -k -X GET "https://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=5s" -u "elastic:changeme"` | **Elasticsearch Cluster Health** |
| `curl -k -X GET "https://localhost:9200/_security/user" -u elastic:changeme` | **List all Elasticsearch users (elastic, kibana, etc.)** |
| `curl -k -X GET "https://localhost:9200/_security/user/kibana"` | **Check Kibana User Details** |
| `curl -k -X GET "https://localhost:9200/_security/service/elastic/kibana"` | **Check Kibana Service Token** |
| `curl -k -X GET "https://localhost:9200/_nodes/stats"` | **Check Elasticsearch Node Stats** |
| `curl -k -X GET "https://localhost:9200/_cat/nodes?v"` | **List Running Elasticsearch Nodes** |
| `curl -k -X GET "https://localhost:9200/_cat/indices?v"` | **List All Elasticsearch Indices** |
| `curl -k -X GET "https://localhost:5601/api/status"` | **Check Kibana Status** |

docker exec -it elasticsearch1 curl -X GET -u elastic:changeme "https://localhost:9200/_cat/indices?v" --insecure


---

## **🚀 Final Summary**
| ✅ Task | ✅ Status |
|---------|---------|
| **Generate SSL Certificates (`generate-certs.sh`)** | ✅ Done |
| **Fix `vm.max_map_count` in WSL (For Docker on Windows)** | ✅ Done |
| **Generate & Set Kibana Authentication Token Automatically** | ✅ Done |
| **Start & Verify ELK Stack (`setup.sh`)** | ✅ Done |
| **Access Kibana Dashboard (`https://localhost:5601`)** | ✅ Done |

🚀 **Congratulations! Your ELK Stack 8.17.1 is fully operational.** 🎉  
If you have any further issues, feel free to reach out! 🚀🔥

docker exec -it logstash ls -lh /usr/share/logstash/config/

docker exec -it logstash /bin/bash


ls -lh /usr/share/logstash/config/mariadb-java-client.jar

chown 1000:1000 ./logstash/config/mariadb-java-client.jar
chmod 644 ./logstash/config/mariadb-java-client.jar


For Windows (Git Bash/PowerShell)
Windows does not use chown, but you can manually set permissions:

Open Git Bash or WSL (Windows Subsystem for Linux) and run:
bash
chown 1000:1000 ./logstash/config/mariadb-java-client.jar
chmod 644 ./logstash/config/mariadb-java-client.jar
powershell
icacls "D:\AIML\AIMI-repo\aiml-labs\logstash\config\mariadb-java-client.jar" /grant Everyone:F


docker exec -it logstash ls -lh /usr/share/logstash/config/
