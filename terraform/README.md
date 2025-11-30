# Strapi Terraform Infrastructure

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ Internet Gateway │
                    └────────┬────────┘
                             │
┌────────────────────────────┼────────────────────────────────────┐
│                       VPC (10.0.0.0/16)                          │
│                                                                  │
│  ┌───────────────────────┬──────────────────────────────────┐   │
│  │   Public Subnet       │      Private Subnets              │   │
│  │   (10.0.1.0/24)       │      (10.0.10.0/24 + 11.0/24)   │   │
│  │                       │                                   │   │
│  │  ┌─────────────────┐  │      ┌─────────────────────┐    │   │
│  │  │  ECS Fargate    │  │      │  RDS PostgreSQL     │    │   │
│  │  │                 │  │      │                     │    │   │
│  │  │  Strapi App     │  │      │  Database           │    │   │
│  │  │  Port: 1337     │◄─┼──────┤  Port: 5432         │    │   │
│  │  │  Public IP      │  │      │  No Internet        │    │   │
│  │  └─────────────────┘  │      └─────────────────────┘    │   │
│  │         │              │                                   │   │
│  └─────────┼──────────────┴──────────────────────────────────┘   │
│            │                                                      │
└────────────┼──────────────────────────────────────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼────┐     ┌─────▼─────┐     ┌─────────────┐
│   S3   │     │    ECR     │     │   Secrets   │
│ Bucket │     │  Registry  │     │   Manager   │
└────────┘     └────────────┘     └─────────────┘
```

## 🔄 How It Works

### Request Flow
1. **User** accesses Strapi via `http://<ECS-PUBLIC-IP>:1337`
2. **Internet Gateway** routes traffic to Public Subnet
3. **ECS Task** receives request on port 1337
4. **Strapi Application** processes request
5. **RDS Database** stores/retrieves data (within VPC)
6. **S3 Bucket** serves uploaded files
7. **Response** sent back to user

### Deployment Flow
1. **Terraform** creates AWS infrastructure
2. **Docker Image** built locally and pushed to **ECR**
3. **ECS Service** pulls image from ECR
4. **ECS Task** starts container with environment variables
5. **Secrets Manager** injects passwords at runtime
6. **CloudWatch** collects logs and metrics

## 📁 File Structure

```
terraform/
├── versions.tf            # Provider configuration (AWS, Random)
├── variables.tf           # Input variables (region, sizes, names)
├── terraform.tfvars       # User-customizable values
│
├── vpc.tf                 # Network infrastructure
│   ├── VPC (10.0.0.0/16)
│   ├── Internet Gateway
│   ├── Public Subnet (10.0.1.0/24)
│   ├── Private Subnets (10.0.10.0/24, 10.0.11.0/24)
│   └── Route Tables
│
├── security-groups.tf     # Firewall rules
│   ├── ECS SG (allow 1337 from internet)
│   └── RDS SG (allow 5432 from ECS only)
│
├── iam.tf                 # IAM roles and policies
│   ├── ECS Execution Role (pull images, read secrets)
│   └── ECS Task Role (S3 access, CloudWatch logs)
│
├── rds.tf                 # PostgreSQL database
│   ├── DB Subnet Group
│   ├── DB Parameter Group
│   ├── DB Instance (db.t3.micro)
│   └── Random Password Generator
│
├── ecs.tf                 # Container service
│   ├── CloudWatch Log Group
│   ├── ECS Cluster
│   ├── ECS Task Definition (256 CPU / 512 MB)
│   └── ECS Service (1 task, public IP)
│
├── ecr.tf                 # Docker image registry
│   ├── ECR Repository
│   └── Lifecycle Policy (keep 10 images)
│
├── s3.tf                  # File storage
│   ├── S3 Bucket
│   ├── Versioning
│   ├── Encryption (AES256)
│   ├── Public Access Policy
│   └── CORS Configuration
│
├── secrets.tf             # Secure credentials storage
│   ├── 7 Random Passwords
│   ├── 7 Secrets in Secrets Manager
│   └── Secret Versions
│
├── monitoring.tf          # Observability
│   ├── ECS CPU Alarm
│   ├── ECS Memory Alarm
│   ├── RDS CPU Alarm
│   ├── RDS Storage Alarm
│   └── CloudWatch Dashboard
│
└── outputs.tf             # Post-deployment information
    ├── VPC ID
    ├── RDS Endpoint
    ├── ECR Repository URL
    ├── ECS Cluster/Service Names
    └── Docker Build Commands
```

## 🔑 Key Components

### Networking
- **VPC**: Isolated network (10.0.0.0/16)
- **Public Subnet**: ECS tasks with internet access
- **Private Subnets**: RDS database (no internet)
- **Internet Gateway**: Connects VPC to internet
- **Security Groups**: Firewall rules for ECS and RDS

### Compute
- **ECS Fargate**: Serverless container platform
- **Task Definition**: Container blueprint (image, CPU, RAM, env vars)
- **Service**: Keeps containers running (auto-restart)

### Storage
- **RDS PostgreSQL**: Managed database (backups, updates)
- **S3 Bucket**: Object storage for uploads
- **ECR**: Private Docker registry

### Security
- **IAM Roles**: Permissions for ECS to access AWS services
- **Secrets Manager**: Encrypted password storage
- **Security Groups**: Network-level firewall

### Monitoring
- **CloudWatch Logs**: Application logs
- **CloudWatch Alarms**: CPU, memory, storage alerts
- **CloudWatch Dashboard**: Visual metrics overview
