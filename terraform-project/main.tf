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
# REGRAS DE SEGURANÇA
# ============================================================================

# 1. Permite que o ALB (Origem) acesse as EC2s Públicas (Destino) na porta 80
# ISSO É ESSENCIAL PARA EVITAR O 504
resource "aws_security_group_rule" "alb_to_public_ec2s" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.net.sg_id      # SG das EC2s (Destino)
  source_security_group_id = module.alb.alb_sg_id  # SG do ALB (Origem)
  description              = "Permite trafego do ALB"
}

# 2. Permite que as EC2s Públicas (Origem) acessem o MySQL (Destino) na porta 3306
resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.net.mysql_sg_id # SG do Banco (Destino)
  source_security_group_id = module.net.sg_id       # SG das EC2s (Origem)
  description              = "Permite Apps acessarem Banco"
}

# 3. Permite SSH do Bastion (EC2s Públicas) para o MySQL
resource "aws_security_group_rule" "bastion_to_db_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.net.mysql_sg_id 
  source_security_group_id = module.net.sg_id       
  description              = "Permite SSH do Bastion"
}

# Outputs
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "ec2_public_1_ip" { value = module.ec2.ec2_public_1_ip }
output "ec2_public_2_ip" { value = module.ec2.ec2_public_2_ip }
output "ec2_private_ip" { value = module.ec2.ec2_private_ip }