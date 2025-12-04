# Security Group do ALB
resource "aws_security_group" "alb_sg" {
  name        = "optimiza-alb-sg"
  description = "Allow HTTP and HTTPS from Internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "optimiza-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  tags = { Name = "optimiza-alb" }
}

# Listener HTTP (80)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# --- Target Groups ---

# 1. Frontend (Nginx :80)
resource "aws_lb_target_group" "frontend_tg" {
  name     = "optimiza-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled = true
    path    = "/"
    matcher = "200"
  }
}

# 2. Django (Nginx -> Gunicorn :8000)
resource "aws_lb_target_group" "django_tg" {
  name     = "optimiza-django-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/chamado/"
    matcher = "200"
  }
}

# 3. Spring Boot (Nginx -> Java :8080)
resource "aws_lb_target_group" "spring_tg" {
  name     = "optimiza-spring-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/optimiza/usuarios/areas"
    matcher = "200,404,401"
  }
}

# --- Attachments ---

resource "aws_lb_target_group_attachment" "frontend_attach" {
  count            = length(var.target_instances)
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = var.target_instances[count.index]
  port             = 80
}

resource "aws_lb_target_group_attachment" "django_attach" {
  count            = length(var.target_instances)
  target_group_arn = aws_lb_target_group.django_tg.arn
  target_id        = var.target_instances[count.index]
  port             = 80
}

resource "aws_lb_target_group_attachment" "spring_attach" {
  count            = length(var.target_instances)
  target_group_arn = aws_lb_target_group.spring_tg.arn
  target_id        = var.target_instances[count.index]
  port             = 80
}

# --- Listener Rules ---

resource "aws_lb_listener_rule" "django_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django_tg.arn
  }
  condition {
    path_pattern { values = ["/chamado/*"] }
  }
}

resource "aws_lb_listener_rule" "spring_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }
  condition {
    path_pattern { values = ["/optimiza/*"] }
  }
}