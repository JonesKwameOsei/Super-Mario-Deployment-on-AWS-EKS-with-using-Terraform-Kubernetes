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

variable "key_file_path" {
  description = "Path to the public key file"
  type        = string
  default     = "id_rsa.pub" # Default value assuming the key file is in the same directory
}

variable "key_name" {
  type        = string
  description = "Name of the keypair to ssh into the instance"
  default     = "MySuperMarioKey"
}

















