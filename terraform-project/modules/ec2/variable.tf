variable "ami" {
  type        = string
  description = "Ubuntu Server 22.04 LTS"
  default     = "ami-0e001c9271cf7f3b9"
}

variable "a_zone" {
  type        = string
  description = "Availability zone"
  default     = "us-east-1a"
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

variable "key_pair_name"{
    type            = string
    default         = "terraform_key"
}