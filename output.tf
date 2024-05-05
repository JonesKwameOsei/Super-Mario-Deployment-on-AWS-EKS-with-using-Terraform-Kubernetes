output "instance_ip_addr" {
  value = aws_instance.supermario_server.public_ip
}

output "name" {
  value = data.aws_key_pair.mario_keypair.key_name
}