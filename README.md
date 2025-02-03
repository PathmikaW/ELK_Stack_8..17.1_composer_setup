# ELK_Stack_8.17.1_Composer_Setup

## 📈 Complete ELK Framework Setup with Docker Compose
This repository contains a **full ELK Stack (Elasticsearch, Logstash, Kibana, Filebeat) setup** using **Docker Compose**. It supports:
- ✅ **Multi-node Elasticsearch cluster** (3 nodes)
- ✅ **SSL/TLS encryption** using self-signed certificates
- ✅ **Kibana, Logstash, and Filebeat integration**
- ✅ **Authentication via Kibana Service Account Token**
- ✅ **Docker-optimized deployment**

---

## **📈 Prerequisites**
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

### **Step 2: Generate SSL Certificates**
Run the script to **generate self-signed SSL certificates**:
```sh
bash scripts/generate-certs.sh
```
👉 **This generates SSL certificates for Elasticsearch, Kibana, and Logstash.**

### **Step 3: Verify Generated Certificates**
Check if all required certificates exist:
```sh
ls -l certs/
```
👉 **Expected Output:**
```
ca.crt
ca.key
ca.srl
elasticsearch1.crt
elasticsearch1.key
elasticsearch1.csr
elasticsearch2.crt
elasticsearch2.key
elasticsearch2.csr
elasticsearch3.crt
elasticsearch3.key
elasticsearch3.csr
```

---

## **🚨 Issue: `vm.max_map_count` Too Low (Bootstrap Check Failed)** due to 3 es nodes
**Elasticsearch requires `vm.max_map_count` to be `262144`.**  
If your current value is too low (`65530`), Elasticsearch **will not start**.

### **🛠️ Fix: Increase `vm.max_map_count` in WSL (For Docker Desktop on Windows)**
1️⃣ **Open PowerShell (Admin) and enter WSL**:
```powershell
wsl -d docker-desktop
```

2️⃣ **Manually set the value inside WSL**:
```sh
sysctl -w vm.max_map_count=262144
```

3️⃣ **Verify the new value**:
```sh
sysctl vm.max_map_count
```
👉 **Expected Output:**
```
vm.max_map_count = 262144
```

4️⃣ **Make it persistent**:
```sh
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
```

5️⃣ **Restart WSL**:
```powershell
wsl --shutdown
wsl -d docker-desktop
```

---

## **🚀 2. Generate and Set a Kibana Service Account Token**
Kibana requires **a service account token** to authenticate with Elasticsearch.

### **📈 Step 1: Manually Generate the Token**
Run this command inside your **Elasticsearch container**:
```sh
docker exec -it elasticsearch1 bin/elasticsearch-service-tokens create elastic/kibana default
```

📈 **Expected Output (Example Token):**
```
eyJ2ZXIiOiI4LjE3LjEiLCJ0b2tlbiI6ImFtUjBuZXJhdGVkX3Rv..."
```
**Copy this token.**

---

### **📈 Step 2: Update `kibana.yml`**
Edit **`kibana/config/kibana.yml`** and replace:
```yaml
elasticsearch.serviceAccountToken: "my-kibana-token"
```
with:
```yaml
elasticsearch.serviceAccountToken: "PASTE_YOUR_GENERATED_TOKEN_HERE"
```

---

### **📈 Step 3: Restart Kibana**
After updating the token, restart Kibana:
```sh
docker-compose restart kibana
```

📈 **Check Kibana logs**:
```sh
docker logs -f kibana
```
👉 **Expected Success Message**:
```
[info][status][plugin:elasticsearch@8.17.1] Status changed from yellow to green - Ready
```

---

## **🚀 3. Start the ELK Stack**
After setting up SSL and authentication, start the **full ELK stack**:
```sh
docker-compose up -d
```
📈 **This will start:**
- **Elasticsearch (3 nodes)**
- **Logstash**
- **Kibana**
- **Filebeat**

### **📈 Verify Everything is Running**
Check running containers:
```sh
docker ps
```
👉 **Expected Output:**
```
CONTAINER ID   IMAGE                                               STATUS          PORTS
abcd1234       docker.elastic.co/elasticsearch/elasticsearch:8.17.1   Up 2 minutes   9200/tcp
efgh5678       docker.elastic.co/kibana/kibana:8.17.1                 Up 2 minutes   5601/tcp
ijkl9012       docker.elastic.co/logstash/logstash:8.17.1             Up 2 minutes   5044/tcp
```

---

## **🛠️ Stop & Restart ELK Stack**
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

## **🚀 Final Summary**
| ✅ Task | ✅ Status |
|---------|---------|
| **Generate SSL Certificates (`generate-certs.sh`)** | ✅ Done |
| **Fix `vm.max_map_count` in WSL (For Docker on Windows)** | ✅ Done |
| **Generate & Set Kibana Authentication Token** | ✅ Done |
| **Start & Verify ELK Stack** | ✅ Done |
| **Access Kibana Dashboard (`https://localhost:5601`)** | ✅ Done |

🚀 **Congratulations! Your ELK Stack 8.17.1 is fully operational.** 🎉  
Let me know if you need further improvements! 🔥

