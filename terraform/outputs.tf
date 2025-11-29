# =============================================================================
# VPC Outputs
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# =============================================================================
# RDS Outputs
# =============================================================================

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_hostname" {
  description = "RDS hostname"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

# =============================================================================
# ECR Outputs
# =============================================================================

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.strapi.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.strapi.name
}

# =============================================================================
# ECS Outputs
# =============================================================================

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}

# =============================================================================
# ALB Outputs
# =============================================================================

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "strapi_admin_url" {
  description = "Strapi Admin URL"
  value       = "http://${aws_lb.main.dns_name}/admin"
}

# =============================================================================
# S3 Outputs
# =============================================================================

output "s3_bucket_name" {
  description = "S3 bucket name for uploads"
  value       = aws_s3_bucket.uploads.id
}

output "s3_bucket_url" {
  description = "S3 bucket URL"
  value       = "https://${aws_s3_bucket.uploads.bucket_regional_domain_name}"
}

# =============================================================================
# Secrets Manager Outputs
# =============================================================================

output "secrets_manager_arn" {
  description = "Secrets Manager ARN"
  value       = aws_secretsmanager_secret.strapi.arn
}

# =============================================================================
# CloudWatch Outputs
# =============================================================================

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# =============================================================================
# Docker Commands
# =============================================================================

output "docker_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.strapi.repository_url}"
}

output "docker_build_push_commands" {
  description = "Commands to build and push Docker image"
  value       = <<-EOT
    # Build the image
    docker build -t ${var.project_name}:latest .
    
    # Tag for ECR
    docker tag ${var.project_name}:latest ${aws_ecr_repository.strapi.repository_url}:latest
    
    # Push to ECR
    docker push ${aws_ecr_repository.strapi.repository_url}:latest
    
    # Force new deployment
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.main.name} --force-new-deployment --region ${var.aws_region}
  EOT
}
