# EC2 instance data configurations
# Inport const ec2InstanceDataConfigurations:
// -------------------------------------------

# Fetch the Latest Ubuntu AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")
}

data "aws_key_pair" "mario_keypair" {
  key_name           = "MyMarioKeyPair"
}


