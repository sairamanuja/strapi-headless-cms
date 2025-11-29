# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false # Set to true for production

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# =============================================================================
# ALB Target Group
# =============================================================================

resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# =============================================================================
# ALB Listener - HTTP (redirect to HTTPS or serve directly)
# =============================================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  # Uncomment below for HTTPS redirect when certificate is available
  # default_action {
  #   type = "redirect"
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }
}

# =============================================================================
# ACM Certificate (Optional - for HTTPS)
# =============================================================================

# Uncomment when you have a domain
# resource "aws_acm_certificate" "main" {
#   count             = var.domain_name != "" ? 1 : 0
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   tags = {
#     Name = "${var.project_name}-cert"
#   }
# }

# =============================================================================
# ALB Listener - HTTPS (Optional - when certificate is available)
# =============================================================================

# Uncomment when you have a certificate
# resource "aws_lb_listener" "https" {
#   count             = var.domain_name != "" ? 1 : 0
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.main[0].arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }
