output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID do Application Load Balancer"
  value       = aws_lb.app_lb.zone_id
}

output "frontend_target_group_arn" {
  description = "ARN do Target Group do Frontend (Nginx)"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "spring_target_group_arn" {
  description = "ARN do Target Group do Backend Spring"
  value       = aws_lb_target_group.spring_tg.arn
}

output "django_target_group_arn" {
  description = "ARN do Target Group do Backend Django"
  value       = aws_lb_target_group.django_tg.arn
}

output "alb_sg_id" {
  description = "ID do Security Group usado pelo ALB"
  value       = aws_security_group.alb_sg.id
}