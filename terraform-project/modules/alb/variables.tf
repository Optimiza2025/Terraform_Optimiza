variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets para o ALB"
  type        = list(string)
}

variable "target_instances" {
  description = "Lista de IDs das instâncias EC2 (Front/Back)"
  type        = list(string)
}