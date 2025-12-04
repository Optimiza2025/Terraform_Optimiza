terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "us-east-1"
}

module "net" {
  source = "./modules/network"
}

module "ec2" {
  source = "./modules/ec2"
  public_subnet_ids  = module.net.subnet_public_ids
  private_subnet_ids = module.net.subnet_private_ids
  sg_id              = module.net.sg_id
  mysql_sg_id        = module.net.mysql_sg_id
  vpc_id             = module.net.vpc_id
}

module "alb" {
  source = "./modules/alb"
  vpc_id     = module.net.vpc_id
  subnet_ids = module.net.subnet_public_ids
  target_instances = [
    module.ec2.ec2_public_1_id,
    module.ec2.ec2_public_2_id
  ]
}

module "s3" { source = "./modules/s3" }
module "sns" {
  source     = "./modules/sns"
  email_list = var.email_list
}
module "lambda" {
  source       = "./modules/lambda"
  email_list   = var.email_list
  raw_arn      = module.s3.raw_arn
  raw_name     = module.s3.raw_name
  trusted_name = module.s3.trusted_name
  topic_arn    = module.sns.topic_arn
}

# ============================================================================
# REGRAS DE SEGURANÇA (CENTRALIZADAS)
# ============================================================================

# --- REGRAS PARA AS EC2s PÚBLICAS (APP/BASTION) ---

# 1. SSH (Permite acesso para você entrar)
resource "aws_security_group_rule" "ssh_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Idealmente, restrinja ao seu IP
  security_group_id = module.net.sg_id
  description       = "SSH Publico"
}

# 2. HTTP vindo do ALB (A Regra que corrige o Timeout)
resource "aws_security_group_rule" "alb_to_app" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.alb.alb_sg_id # Vindo do ALB
  security_group_id        = module.net.sg_id
  description              = "Trafego do ALB para Nginx"
}

# --- REGRAS PARA O BANCO DE DADOS (PRIVADO) ---

# 3. MySQL vindo das Apps (EC2s Públicas)
resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.net.sg_id      # Vindo das Apps
  security_group_id        = module.net.mysql_sg_id
  description              = "Acesso App ao Banco"
}

# 4. SSH vindo do Bastion (Para você gerenciar o banco)
resource "aws_security_group_rule" "bastion_to_db" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.net.sg_id      # Vindo do Bastion
  security_group_id        = module.net.mysql_sg_id
  description              = "SSH do Bastion"
}

# Outputs
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "ec2_public_1_ip" { value = module.ec2.ec2_public_1_ip }
output "ec2_public_2_ip" { value = module.ec2.ec2_public_2_ip }
output "ec2_private_ip" { value = module.ec2.ec2_private_ip }