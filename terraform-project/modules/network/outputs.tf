output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_public_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "subnet_private_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "sg_id" {
  value = aws_security_group.sg.id
}

output "mysql_sg_id" {
  value = aws_security_group.mysql_sg.id
}