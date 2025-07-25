# TNIS Test T2 - Sistem Logging dan Observability

## Overview
Proyek ini merupakan implementasi **Logging dan Observability Sistem dengan OpenSearch** yang terdiri dari aplikasi web (frontend/backend), reverse proxy (Nginx), sistem logging (FluentBit), dan search engine (OpenSearch) yang di-deploy menggunakan Ansible automation.

## Deliverable Hasil Test Case

### Arsitektur Sistem
- Nginx reverse proxy dengan SSL termination - Port 80/443
- Frontend service (Python) - Port 3000
- Backend service (Go) - Port 8080
- FluentBit log processor untuk real-time log processing
- OpenSearch cluster (2 nodes) untuk log storage dan search
- OpenSearch Dashboard untuk visualisasi log - Port 5601

### Infrastructure as Code
- Playbook deployment otomatis (`ansible/playbooks/deploy.yml`)
- Role-based configuration:
  - `common`: Base system setup
  - `nginx`: Web server dan SSL configuration
  - `opensearch`: Search engine dan log processing setup
- Inventory management dengan variabel terpusat
- Template-based configuration management

### Containerization
- Multi-container application dengan Docker Compose
- Custom Docker images untuk setiap service
- Persistent volumes untuk data storage
- Health checks untuk semua services
- Network isolation dengan custom bridge network

### Logging Pipeline
- Nginx access dan error logs dalam format JSON
- FluentBit untuk log collection, parsing, dan forwarding
- Real-time log streaming ke OpenSearch
- Log indexing dengan daily rotation pattern
- Structured logging untuk better searchability

### Monitoring & Observability
- Health checks untuk semua services
- Service dependency management
- Log aggregation dan centralized monitoring
- Performance metrics collection
- Dashboard untuk log visualization

## Command Deployment

### Prerequisites
```bash
# Install Ansible
pip3 install ansible

# Install required Ansible collections
ansible-galaxy install -r ansible/requirements.yml

# Verify SSH access ke target server
ssh root@10.212.13.50
```

### 1. Deployment Menggunakan Ansible

#### Step 1: Verifikasi Inventory
```bash
# Masuk ke direktori ansible
cd /Users/ghifari/tnis-test-t2/ansible

# Verifikasi inventory configuration
ansible-inventory --list -i inventory/hosts.yml

# Test koneksi ke target server
ansible all -i inventory/hosts.yml -m ping
```

#### Step 2: Deploy Full Stack
```bash
# Deploy semua komponen sistem
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml

# Deploy dengan verbose output untuk debugging
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml -v

# Deploy specific role saja (opsional)
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml --tags "nginx"
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml --tags "opensearch"
```

#### Step 3: Verifikasi Deployment
```bash
# Check status semua services
ansible all -i inventory/hosts.yml -m shell -a "docker ps"

# Check logs deployment
ansible all -i inventory/hosts.yml -m shell -a "docker-compose -f /opt/logging-system/docker-compose.yml logs --tail=50"

# Verify network connectivity
ansible all -i inventory/hosts.yml -m shell -a "docker network ls"
```

### 2. Manual Deployment (Alternative)

#### Step 1: Setup Environment
```bash
# Copy docker configuration ke server
scp -r docker/ root@10.212.13.50:/opt/logging-system/

# SSH ke server
ssh root@10.212.13.50

# Masuk ke direktori deployment
cd /opt/logging-system
```

#### Step 2: Deploy Services
```bash
# Start semua services
docker-compose up -d

# Monitor deployment progress
docker-compose logs -f

# Check service status
docker-compose ps
```

### 3. Verifikasi dan Testing

#### Health Check Services
```bash
# Check frontend service
curl -I http://10.212.13.50:3000

# Check backend service
curl -I http://10.212.13.50:8080

# Check Nginx dengan SSL
curl -I https://frontend.abdurrahmanalghifari.my.id

# Check OpenSearch cluster
curl -k -u admin:d3l4p4Nk@r4kt3er https://10.212.13.50:9200/_cluster/health

# Check OpenSearch Dashboard
curl -I http://10.212.13.50:5601

# Check FluentBit health
curl http://172.99.0.5:2020/api/v1/health
```

#### Log Verification
```bash
# Generate test traffic
for i in {1..10}; do
  curl -s https://frontend.abdurrahmanalghifari.my.id > /dev/null
  sleep 1
done

# Check Nginx logs
docker exec nginx-development tail -f /var/log/nginx/access-fe-json.log

# Verify logs di OpenSearch
curl -k -u admin:d3l4p4Nk@r4kt3er \
  "https://10.212.13.50:9200/frontend-*/_search?pretty&size=5"
```

### 4. Monitoring dan Maintenance

#### Service Management
```bash
# Restart specific service
docker-compose restart nginx
docker-compose restart fluentbit

# View service logs
docker-compose logs -f nginx
docker-compose logs -f opensearch-node1

# Scale services (jika diperlukan)
docker-compose up -d --scale backend=2
```

#### Log Analysis
```bash
# Access OpenSearch Dashboard
open http://10.212.13.50:5601

# Create index pattern: frontend-*
# Create index pattern: error-frontend-*

# Query logs via API
curl -k -u admin:d3l4p4Nk@r4kt3er \
  -H "Content-Type: application/json" \
  -X POST "https://10.212.13.50:9200/frontend-*/_search" \
  -d '{
    "query": {
      "range": {
        "@timestamp": {
          "gte": "now-1h"
        }
      }
    },
    "size": 100
  }'
```

## Access Information

Setelah deployment berhasil, akses sistem melalui:

🌐 **Web Application**
- Frontend: https://frontend.abdurrahmanalghifari.my.id
- Backend API: http://10.212.13.50:8080

📊 **Monitoring Dashboard**
- OpenSearch Dashboard: http://10.212.13.50:5601
- Username: admin
- Password: d3l4p4Nk@r4kt3er

🔍 **Direct API Access**
- OpenSearch API: https://10.212.13.50:9200
- FluentBit Health: http://172.99.0.5:2020/api/v1/health

## Dokumentasi Tambahan

- [Architecture Diagram](./architecture-diagram.md) - Dokumentasi lengkap arsitektur sistem
- [Docker Configuration](./docker/) - Konfigurasi Docker Compose dan environment
- [Ansible Playbooks](./ansible/) - Automation scripts dan configuration management
- [Dockerfile Sources](./dockerfile/) - Source code dan Dockerfile untuk custom images

---

**Test Case Status**: **COMPLETED**

Semua komponen telah berhasil di-deploy dan terintegrasi dengan baik. Sistem logging dan monitoring berjalan dengan optimal dan siap untuk production use.