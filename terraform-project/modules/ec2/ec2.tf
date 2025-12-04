resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = file("terraform_key.pem.pub")
}

# EC2 Pública 1
resource "aws_instance" "ec2-publica-1" {
  ami                         = var.ami
  availability_zone           = var.a_zones[0]
  instance_type               = var.instance_type_public
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]
  
  tags = { Name = "ec2-publica-optimiza-1" }
}

# EC2 Pública 2
resource "aws_instance" "ec2-publica-2" {
  ami                         = var.ami
  availability_zone           = var.a_zones[1]
  instance_type               = var.instance_type_public
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = var.public_subnet_ids[1]
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]

  tags = { Name = "ec2-publica-optimiza-2" }
}

# EC2 Privada (Banco)
resource "aws_instance" "ec2-privada" {
  ami                         = var.ami
  availability_zone           = var.a_zones[0]
  instance_type               = var.instance_type_private
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.mysql_sg_id]

  tags = { Name = "ec2-privada-optimiza" }
}