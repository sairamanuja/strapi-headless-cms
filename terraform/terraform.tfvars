# =============================================================================
# SIMPLIFIED CONFIGURATION FOR JUNIOR DEVELOPERS
# =============================================================================
# This file contains all the settings you can customize
# Edit these values before running "terraform apply"

# =============================================================================
# General Settings
# =============================================================================

aws_region   = "ap-south-1" # Mumbai region (change to your preferred region)
project_name = "strapi"     # Project name (used in resource names)
environment  = "prod"       # Environment name (dev/staging/prod)

# =============================================================================
# VPC Settings (Network Configuration)
# =============================================================================

vpc_cidr            = "10.0.0.0/16"  # VPC IP range (65,536 addresses)
availability_zone   = "ap-south-1a"  # Single AZ (data center) to save money
public_subnet_cidr  = "10.0.1.0/24"  # Public subnet (256 addresses for ECS)
private_subnet_cidr = "10.0.10.0/24" # Private subnet (256 addresses for RDS)

# =============================================================================
# Database Settings (RDS PostgreSQL)
# =============================================================================

db_instance_class        = "db.t3.micro" # Smallest instance (~$12-15/month)
db_name                  = "strapidb"    # Database name
db_username              = "strapi"      # Master username
db_allocated_storage     = 20            # Initial storage: 20 GB
db_max_allocated_storage = 100           # Can auto-grow to 100 GB

# Password is auto-generated and stored in AWS Secrets Manager (secure!)

# =============================================================================
# ECS Settings (Container Configuration)
# =============================================================================

ecs_cpu           = 256  # 0.25 vCPU (very small, cheapest option)
ecs_memory        = 512  # 512 MB RAM (0.5 GB, minimal but works)
ecs_desired_count = 1    # Run 1 container (increase to 2+ for high availability)
container_port    = 1337 # Strapi default port

# Cost for these settings: ~$8-10/month
# To reduce cost further: Keep these values as-is
# To handle more traffic: Increase to ecs_cpu=512, ecs_memory=1024

# =============================================================================
# S3 Settings (File Storage)
# =============================================================================

s3_bucket_name = "strapi-uploads-ram" # ⚠️ MUST BE GLOBALLY UNIQUE!
# Change this to something unique (add your name/numbers)
# Example: "myname-strapi-uploads-2024"

# =============================================================================
# Domain Settings (Optional - Not Used in Simplified Architecture)
# =============================================================================

domain_name       = ""    # Leave empty (we don't use domains, access via IP)
create_dns_record = false # Keep false

# =============================================================================
# NOTES FOR JUNIOR DEVELOPERS:
# =============================================================================
# 1. MUST CHANGE: s3_bucket_name (must be globally unique)
# 2. Optional: aws_region (if not in India)
# 3. Keep other values as-is to minimize cost
# 4. After changing, save and run: terraform plan
# =============================================================================
