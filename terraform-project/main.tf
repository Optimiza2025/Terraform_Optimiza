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
  region  = "us-east-1"
}

module "ec2" {
    source = "./modules/ec2"
}

module "net" {
    source = "./modules/network"
}

module "s3" {
  source = "./modules/s3"
}

module "sns" {
  source = "./modules/sns"
  email_list = var.email_list
}

module "lambda" {
  source            = "./modules/lambda"
  email_list        = var.email_list
  raw_arn           = module.s3.raw_arn
  raw_name          = module.s3.raw_name
  trusted_name      = module.s3.trusted_name
  topic_arn         = module.sns.topic_arn
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.net.vpc_id
  subnet_ids        = module.net.subnet_public_ids
  security_group_id = module.net.sg_id
  target_instances  = [module.ec2.ec2_public_1_id, module.ec2.ec2_public_2_id]
}

# Outputs
output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ec2_public_1_ip" {
  description = "IP público da primeira EC2"
  value       = module.ec2.ec2_public_1_ip
}

output "ec2_public_2_ip" {
  description = "IP público da segunda EC2"
  value       = module.ec2.ec2_public_2_ip
}

output "ec2_private_ip" {
  description = "IP privado da EC2 do banco"
  value       = module.ec2.ec2_private_ip
}