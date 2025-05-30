variable "ami" {
  type        = string
  description = "AMI ID"
}

variable "a_zone" {
  type        = string
  description = "Availability zone"
}

variable "instance_type_public" {
  type        = string
  default     = "t3.small"
}

variable "instance_type_private" {
  type        = string
  default     = "t3.small"
}

variable "volume_size" {
  type        = number
  default     = 30
}

variable "volume_type" {
  type        = string
  default     = "gp3"
}