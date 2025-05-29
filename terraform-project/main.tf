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