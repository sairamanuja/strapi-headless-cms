# Strapi Terraform Infrastructure

This Terraform configuration deploys a production-ready Strapi CMS on AWS.

## Architecture

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                         VPC                                  │
                                    │  ┌────────────────────────┐  ┌────────────────────────┐     │
                                    │  │    Public Subnet 1     │  │    Public Subnet 2     │     │
                   Internet         │  │    (ap-south-1a)       │  │    (ap-south-1b)       │     │
                      │             │  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │     │
                      │             │  │  │   NAT Gateway    │  │  │  │   NAT Gateway    │  │     │
                      ▼             │  │  └──────────────────┘  │  │  └──────────────────┘  │     │
               ┌─────────────┐      │  │                        │  │                        │     │
               │     ALB     │◄─────┼──┼────────────────────────┼──┼────────────────────────┼─────┤
               └─────────────┘      │  └────────────────────────┘  └────────────────────────┘     │
                      │             │                                                              │
                      │             │  ┌────────────────────────┐  ┌────────────────────────┐     │
                      │             │  │   Private Subnet 1     │  │   Private Subnet 2     │     │
                      │             │  │    (ap-south-1a)       │  │    (ap-south-1b)       │     │
                      ▼             │  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │     │
               ┌─────────────┐      │  │  │   ECS Fargate    │  │  │  │   RDS Postgres   │  │     │
               │ ECS Service │──────┼──┼──►   (Strapi)       │──┼──┼──►   (Primary)      │  │     │
               └─────────────┘      │  │  └──────────────────┘  │  │  └──────────────────┘  │     │
                      │             │  └────────────────────────┘  └────────────────────────┘     │
                      │             └─────────────────────────────────────────────────────────────┘
                      │
                      ▼
               ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
               │     S3      │      │   Secrets   │      │ CloudWatch  │
               │  (Uploads)  │      │   Manager   │      │   (Logs)    │
               └─────────────┘      └─────────────┘      └─────────────┘
```

## Resources Created

- **VPC** with public & private subnets across 2 AZs
- **RDS PostgreSQL** in private subnets
- **ECR** repository for Docker images
- **ECS Fargate** cluster and service
- **Application Load Balancer** in public subnets
- **S3 Bucket** for media uploads
- **Secrets Manager** for sensitive configuration
- **CloudWatch** logs, alarms, and dashboard
- **IAM Roles** for ECS tasks

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. Docker installed (for building images)

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review the plan

```bash
terraform plan
```

### 3. Apply the infrastructure

```bash
terraform apply
```

### 4. Build and push Docker image

After Terraform creates the infrastructure, push your Strapi image:

```bash
# Navigate to strapi directory
cd ../my-strapi

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $(terraform -chdir=../terraform output -raw ecr_repository_url | cut -d/ -f1)

# Build the image
docker build -t strapi:latest .

# Tag for ECR
docker tag strapi:latest $(terraform -chdir=../terraform output -raw ecr_repository_url):latest

# Push to ECR
docker push $(terraform -chdir=../terraform output -raw ecr_repository_url):latest
```

### 5. Force ECS deployment

```bash
aws ecs update-service \
  --cluster $(terraform -chdir=../terraform output -raw ecs_cluster_name) \
  --service $(terraform -chdir=../terraform output -raw ecs_service_name) \
  --force-new-deployment \
  --region ap-south-1
```

### 6. Access the application

```bash
# Get the ALB URL
terraform output alb_url

# Get the Strapi admin URL
terraform output strapi_admin_url
```

## Configuration

Edit `terraform.tfvars` to customize:

```hcl
# Region and naming
aws_region   = "ap-south-1"
project_name = "strapi"
environment  = "prod"

# RDS sizing
db_instance_class = "db.t3.micro"

# ECS sizing
ecs_cpu    = 512   # 0.5 vCPU
ecs_memory = 1024  # 1 GB

# S3 bucket (must be globally unique)
s3_bucket_name = "your-unique-bucket-name"
```

## Outputs

| Output | Description |
|--------|-------------|
| `alb_url` | Application URL |
| `strapi_admin_url` | Strapi Admin Panel URL |
| `ecr_repository_url` | ECR repository for Docker images |
| `rds_endpoint` | RDS database endpoint |
| `s3_bucket_url` | S3 bucket URL for uploads |
| `cloudwatch_dashboard_url` | CloudWatch dashboard URL |

## Cost Estimation

Approximate monthly costs (ap-south-1):

| Resource | Estimated Cost |
|----------|---------------|
| RDS db.t3.micro | ~$15 |
| ECS Fargate (0.5 vCPU, 1GB) | ~$25 |
| NAT Gateway (2x) | ~$65 |
| ALB | ~$20 |
| S3 | ~$1 (varies with usage) |
| **Total** | **~$125/month** |

### Cost Optimization Tips

1. Use single NAT Gateway instead of two (less HA, but cheaper)
2. Use Fargate Spot for non-production
3. Use smaller RDS instance for dev/staging

## HTTPS Setup

1. Register a domain in Route53 or add your domain
2. Uncomment the ACM certificate in `alb.tf`
3. Uncomment the HTTPS listener in `alb.tf`
4. Update `domain_name` in `terraform.tfvars`

## Cleanup

```bash
terraform destroy
```

**Note:** S3 bucket must be emptied before destruction.

## Troubleshooting

### ECS tasks not starting
```bash
# Check ECS service events
aws ecs describe-services --cluster strapi-cluster --services strapi-service --region ap-south-1

# Check CloudWatch logs
aws logs tail /ecs/strapi --follow --region ap-south-1
```

### Database connection issues
- Ensure RDS security group allows traffic from ECS security group
- Check if DATABASE_SSL=true is set
- Verify secrets are correctly stored in Secrets Manager

### S3 upload issues
- Verify S3 bucket policy allows public read
- Check ECS task role has S3 permissions
- Ensure ACL is set to null (bucket doesn't allow ACLs)
