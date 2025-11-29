# Production Environment Configuration
# Customize these values for your deployment

aws_region   = "ap-south-1"
project_name = "strapi"
environment  = "prod"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# RDS
db_instance_class        = "db.t3.micro"  # Use db.t3.small or larger for production
db_name                  = "strapidb"
db_username              = "strapi"
db_allocated_storage     = 20
db_max_allocated_storage = 100

# ECS
ecs_cpu           = 512   # 0.5 vCPU
ecs_memory        = 1024  # 1 GB
ecs_desired_count = 1     # Increase for HA
container_port    = 1337

# S3
s3_bucket_name = "strapi-uploads-ram"  # Must be globally unique

# Domain (Optional)
domain_name       = ""
create_dns_record = false
