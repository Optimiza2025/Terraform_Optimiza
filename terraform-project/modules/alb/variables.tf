variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets públicas do ALB"
  type        = list(string)
}

variable "target_instances" {
  description = "Lista de IDs das instâncias EC2 que o ALB irá balancear"
  type        = list(string)
}

variable "grafana_instance_id" {
  description = "ID da instância Grafana para o Target Group"
  type        = string
}