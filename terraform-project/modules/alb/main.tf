# modules/alb/main.tf

# Security Group do ALB (Definido AQUI para ser autocontido)
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
  security_groups    = [aws_security_group.alb_sg.id] # Usa o SG criado acima
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
  port     = 80 # O ALB fala com o Nginx na 80, que faz proxy_pass para 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/chamado/" # Caminho que o Nginx roteia para o Django
    matcher = "200"
  }
}

# 3. Spring Boot (Nginx -> Java :8080)
resource "aws_lb_target_group" "spring_tg" {
  name     = "optimiza-spring-tg"
  port     = 80 # O ALB fala com o Nginx na 80, que faz proxy_pass para 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    # Opção A (Recomendada se tiver endpoint):
    path    = "/optimiza/usuarios/areas" # Um endpoint real da API
    matcher = "200,404,401" # Aceita erros de 'not found' ou 'auth' como sinal de vida
    
    # Opção B (Se não tiver endpoint fácil):
    # path    = "/optimiza/"
    # matcher = "200,404"
  }
}

# 4. Grafana (:3000)
resource "aws_lb_target_group" "grafana_tg" {
  name     = "optimiza-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/api/health"
    matcher = "200"
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

resource "aws_lb_target_group_attachment" "grafana_attach" {
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = var.grafana_instance_id
  port             = 3000
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

resource "aws_lb_listener_rule" "grafana_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 30
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
  condition {
    path_pattern { values = ["/grafana/*"] }
  }
}