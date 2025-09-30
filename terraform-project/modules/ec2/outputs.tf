output "ec2_public_1_id" {
  value = aws_instance.ec2-publica-1.id
}

output "ec2_public_2_id" {
  value = aws_instance.ec2-publica-2.id
}

output "ec2_private_id" {
  value = aws_instance.ec2-privada.id
}

output "ec2_public_1_ip" {
  value = aws_instance.ec2-publica-1.public_ip
}

output "ec2_public_2_ip" {
  value = aws_instance.ec2-publica-2.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.ec2-privada.private_ip
}