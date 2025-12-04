output "ec2_public_1_id" {
  description = "ID da primeira EC2 pública"
  value       = aws_instance.ec2-publica-1.id
}

output "ec2_public_2_id" {
  description = "ID da segunda EC2 pública"
  value       = aws_instance.ec2-publica-2.id
}

output "ec2_public_1_ip" {
  description = "IP público da primeira EC2"
  value       = aws_instance.ec2-publica-1.public_ip
}

output "ec2_public_2_ip" {
  description = "IP público da segunda EC2"
  value       = aws_instance.ec2-publica-2.public_ip
}

output "ec2_private_ip" {
  description = "IP privado da EC2 privada (MySQL)"
  value       = aws_instance.ec2-privada.private_ip
}

output "grafana_instance_id" {
  description = "ID da instância EC2 do Grafana"
  value       = aws_instance.ec2-grafana.id
}

output "grafana_sg_id" {
  description = "ID do Security Group do Grafana"
  value       = aws_security_group.grafana_sg.id
}