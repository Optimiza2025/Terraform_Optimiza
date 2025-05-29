variable "raw_name" {
  description = "Nome do bucket que aciona o Lambda"
  type        = string
}

variable "raw_arn" {
  description = "ARN do bucket que aciona o Lambda"
  type        = string
}

variable "trusted_name" {
  description = "Nome do bucket que recebe os arquivos tratados"
  type        = string
} 

variable "topic_arn"{
  description = "ARN do tópico SNS"
  type        = string
}
variable "email_list" {
  description = "Lista de e-mails que vão receber notificações do SNS"
  type        = list(string)
}