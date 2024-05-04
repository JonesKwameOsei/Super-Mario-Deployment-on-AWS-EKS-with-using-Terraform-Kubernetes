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

variable "keypair" {
  description = "public-key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuW8qGcHPTdPrGcum4GwnNlvFqNVW5uSk/kS7mXCkP6 KWAME@DESKTOP-Q57LJF8" # Default value assuming the key file is in the same directory
}

variable "key_name" {
  type        = string
  description = "Name of the keypair to ssh into the instance"
  default     = "MySuperMarioKey"
}

















