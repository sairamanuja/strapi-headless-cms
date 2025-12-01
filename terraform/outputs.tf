output "ecr_url" {
  description = "Copy this URL to push Docker images"
  value       = aws_ecr_repository.strapi.repository_url
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = aws_db_instance.main.endpoint
}

output "s3_bucket" {
  description = "S3 bucket for file uploads"
  value       = aws_s3_bucket.uploads.id
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
    
    ✅ Infrastructure deployed successfully!
    
    STEP 1: Build and push your Docker image
    -----------------------------------------------
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.strapi.repository_url}
    docker build -t strapi .
    docker tag strapi:latest ${aws_ecr_repository.strapi.repository_url}:latest
    docker push ${aws_ecr_repository.strapi.repository_url}:latest
    
    STEP 2: Deploy to ECS
    -----------------------------------------------
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.main.name} --force-new-deployment --region ${var.aws_region}
    
    STEP 3: Get your application URL (wait 2-3 minutes after deployment)
    -----------------------------------------------
    aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --region ${var.aws_region} --output text | head -n1 | awk '{print $2}' | xargs aws ecs describe-tasks --cluster ${aws_ecs_cluster.main.name} --tasks --region ${var.aws_region} --query 'tasks[0].attachments[0].details[?name==\`networkInterfaceId\`].value' --output text | xargs aws ec2 describe-network-interfaces --network-interface-ids --region ${var.aws_region} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    
    STEP 4: Access your application
    -----------------------------------------------
    Open: http://<PUBLIC_IP>:1337
    Admin: http://<PUBLIC_IP>:1337/admin
    
    View logs: aws logs tail /ecs/${var.project_name} --follow --region ${var.aws_region}
    
  EOT
}
