variable "instance_type" {
  type        = string
  description = "EC2 Instance type to run"
  default     = "t2.micro"
}

variable "name" {
  type        = string
  description = "Name of the instance and resources"
  default     = "Supermario_server"
}

variable "key_name" {
  type        = string
  description = "Name of the keypair to ssh into the instance"
  default     = "MySuperMarioKey"
}

















