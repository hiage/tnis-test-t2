# Dokumentasi Arsitektur Sistem Logging dan Observability

## Overview
Berikut merupakan gambaran arsitektur dan integrasi antar sistem.

## Component Architecture

### 1. Infrastructure
```
┌─────────────────────────────────────────────────────────────────┐
│                        Host Server                              │
│                    IP: 10.212.13.50                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                Docker Network                           │    │
│  │                Subnet: 172.99.0.0/24                    │    │
│  │                                                         │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │    │
│  │  │ Nginx    │  │Frontend  │  │Backend   │  │FluentBit │ │    │
│  │  │172.99.0.2│  │172.99.0.3│  │172.99.0.4│  │172.99.0.5│ │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │    │
│  │                                                         │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐               │    │
│  │  │OpenSearch│  │OpenSearch│  │OpenSearch│               │    │
│  │  │  Node1   │  │  Node2   │  │Dashboard │               │    │
│  │  │172.99.0.6│  │172.99.0.7│  │172.99.0.8│               │    │
│  │  └──────────┘  └──────────┘  └──────────┘               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Proxy Layer
#### Nginx Reverse Proxy
- **Image**: `nginx:latest`
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **IP**: 172.99.0.2
- **Function**: 
  - SSL termination
  - Reverse Proxy
  - Access logging
- **SSL Configuration**:
  - Certificate: `/etc/nginx/ssl/server.pem`
  - Private Key: `/etc/nginx/ssl/server.key`
  - Protocols: TLSv1.2, TLSv1.1, TLSv1
- **Domain**: `frontend.abdurrahmanalghifari.my.id`
- **Log Format**: JSON structured logging
- **Log Files**:
  - Access: `/var/log/nginx/access-fe-json.log`
  - Error: `/var/log/nginx/error-fe.log`

### Application Layer

#### Frontend Service
- **Image**: `docker.io/hiage/frontend:development`
- **Port**: 3000
- **IP**: 172.99.0.3
- **Function**: User interface aplikasi web
- **Dependencies**: Backend API
- **Environment**: 
  - `BACKEND_API`: 172.99.0.4:8080

#### Backend Service
- **Image**: `docker.io/hiage/backend:development`
- **Port**: 8080
- **IP**: 172.99.0.4
- **Function**: API server dan business logic
- **Dependencies**: None (independent service)

### Logging Layer

#### FluentBit Log
- **Image**: `docker.io/hiage/fluent-bit:4.0.5`
- **IP**: 172.99.0.5
- **Function**: 
  - Log collection dari Nginx
  - Log parsing dan transformation
  - Log forwarding ke OpenSearch
- **Input Sources**:
  - Nginx access logs: `/var/log/nginx/access-*log*`
  - Nginx error logs: `/var/log/nginx/error-*`
- **Output Destinations**:
  - OpenSearch cluster (nodes 1 & 2)
- **Storage**: `/fluent-bit/storage` (filesystem-based buffering)
- **Health Check**: HTTP endpoint pada port 2020

### Monitoring dan Observability

#### OpenSearch Cluster

##### OpenSearch Node 1
- **Image**: `opensearchproject/opensearch:latest`
- **Port**: 9200 (HTTP)
- **IP**: 172.99.0.6
- **Storage**: Persistent volume `opensearch-data1`
- **Memory**: 512MB heap size

##### OpenSearch Node 2
- **Image**: `opensearchproject/opensearch:latest`
- **IP**: 172.99.0.7
- **Storage**: Persistent volume `opensearch-data2`
- **Memory**: 512MB heap size

##### OpenSearch Dashboard
- **Image**: `opensearchproject/opensearch-dashboards:latest`
- **Port**: 5601
- **IP**: 172.99.0.8
- **Function**: Web UI untuk visualisasi dan analisis data
- **Connected to**: OpenSearch Node 1 & 2

## Deployment Flow Architecture

### User to Ansible to System Deployment

```
┌───────────────────┐    SSH/22        ┌─────────────┐    Docker API    ┌─────────────┐
│    User           │ ───────────────► │   Ansible   │ ───────────────► │   Docker    │
│ (System Engineer) │                  │ Controller  │                  │   Engine    │
└───────────────────┘                  └─────────────┘                  └─────────────┘
                                              │                                 │
                                              │ Playbook Execution              │ Container
                                              │                                 │ 
                                              ▼                                 ▼
                                       ┌─────────────┐                   ┌─────────────┐
                                       │   Target    │                   │ Application │
                                       │   Server    │                   │  Services   │
                                       │10.212.13.50 │                   │   Stack     │
                                       └─────────────┘                   └─────────────┘
```

### Ansible Deployment Workflow

```
┌─────────────┐
│    User     │
│  Commands   │
└─────────────┘
       │
       │ ansible-playbook deploy.yml
       ▼
┌─────────────┐    Role: common    ┌─────────────┐
│   Ansible   │ ─────────────────► │ Base System │
│ Controller  │                    │    Setup    │
└─────────────┘                    └─────────────┘
       │                                  │
       │ Role: docker                     │ Install packages
       ▼                                  │ Create directories
┌─────────────┐                           ▼
│   Docker    │                   ┌─────────────┐
│Installation │                   │ System Prep │
└─────────────┘                   │  Complete   │
       │                          └─────────────┘
       │ Role: nginx
       ▼
┌─────────────┐    SSL Certs       ┌─────────────┐
│    Nginx    │ ◄───────────────── │   Config    │
│   Service   │                    │ Templates   │
└─────────────┘                    └─────────────┘
       │
       │ Role: opensearch
       ▼
┌─────────────┐    Docker Compose  ┌─────────────┐
│ OpenSearch  │ ◄───────────────── │   Stack     │
│   Stack     │                    │ Deployment  │
└─────────────┘                    └─────────────┘
```

## Log Data Flow Architecture

```
┌─────────────┐    HTTPS/443     ┌─────────────┐                 ┌─────────────┐                ┌─────────────┐
│   Internet  │ ───────────────► │    Nginx    │───────────────► │  Frontend   │───────────────►│  Backend    │
│   Users     │                  │ Reverse     │                 │  Service    │                │  Service    │
└─────────────┘                  │ Proxy       │                 └─────────────┘                └─────────────┘
                                 └─────────────┘
                                        │
                                        │ Log files
                                        ▼
                                 ┌─────────────┐
                                 │  Nginx      │
                                 │  Logging    │
                                 └─────────────┘
                                        │
                                        │ Read file log
                                        ▼
                                 ┌─────────────┐
                                 │  FluentBit  │
                                 │Log Processor│
                                 └─────────────┘
                                        │
                                        │ HTTPS/9200
                                        ▼
                                 ┌─────────────┐
                                 │ OpenSearch  │
                                 │  Cluster    │
                                 └─────────────┘
                                        │
                                        │ Query API
                                        ▼
                                 ┌─────────────┐
                                 │ OpenSearch  │
                                 │ Dashboard   │
                                 └─────────────┘
```

## Network Configuration

### Docker Network
- **Name**: `netstack`
- **Subnet**: `172.99.0.0/24`
- **Type**: Custom bridge network

### Port Mapping
| Service | Internal Port | External Port | Protocol |
|---------|---------------|---------------|---------|
| Nginx | 80, 443 | 80, 443 | HTTP/HTTPS |
| Frontend | 3000 | 3000 | HTTP |
| Backend | 8080 | 8080 | HTTP |
| OpenSearch Node1 | 9200, 9600 | 9200, 9600 | HTTPS |
| OpenSearch Dashboard | 5601 | 5601 | HTTP |
| FluentBit | 2020 | - | HTTP (Health) |

## Security Configuration

### SSL/TLS
- **Nginx SSL**: Custom certificates untuk domain `frontend.abdurrahmanalghifari.my.id`
- **OpenSearch**: Internal TLS untuk cluster communication
- **FluentBit to OpenSearch**: TLS enabled dengan verification disabled

### Authentication
- **OpenSearch Cluster**:
  - Username: `admin`
  - Password: `d3l4p4Nk@r4kt3er`
  - Initial admin password: `d3l4p4Nk@r4kt3er`

### Access Control
- **Nginx**: Reverse proxy dengan SSL termination
- **Internal Services**: Komunikasi melalui Docker network internal
- **OpenSearch**: Basic authentication untuk FluentBit

## Storage & Persistence

### Volumes
- **OpenSearch Data**:
  - `opensearch-data1`: Node 1 data persistence
  - `opensearch-data2`: Node 2 data persistence
- **Shared Volumes**:
  - `/var/log/nginx`: Shared antara Nginx dan FluentBit
  - `/opt/logging-system/configs`: Configuration files

### Log Management
- **Nginx Logs**: JSON format untuk structured logging

## Deployment Architecture

### Ansible Automation
- **Inventory**: Single host deployment (`test-t2: 10.212.13.50`)
- **Roles**:
  - `common`: Base system setup
  - `docker`: Docker installation and configuration
  - `nginx`: Nginx configuration dan SSL setup
  - `opensearch`: OpenSearch cluster dan FluentBit setup

### Configuration Management
- **Templates**: Jinja2 templates untuk dynamic configuration
- **Variables**: Centralized dalam inventory untuk easy management
- **Secrets**: Environment variables untuk sensitive data

## Monitoring & Health Checks

### Service Health Checks
| Service | Health Check | Interval | Timeout |
|---------|--------------|----------|--------|
| Frontend | HTTP GET :3000 | 5s | 10s |
| Backend | HTTP GET :8080 | 1s | 3s |
| Nginx | HTTP HEAD localhost | 10s | 3s |
| FluentBit | HTTP GET :2020/api/v1/health | 30s | 10s |
| OpenSearch | HTTPS HEAD :9200 | 10s | 3s |
| Dashboard | HTTP HEAD :5601 | 10s | 3s |

### Log Indexing
- **Frontend Logs**: Index pattern `frontend-YYYY.MM.DD`
- **Error Logs**: Index pattern `error-frontend-YYYY.MM.DD`
- **Format**: Logstash format dengan daily rotation