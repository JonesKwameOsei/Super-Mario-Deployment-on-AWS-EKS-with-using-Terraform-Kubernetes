# resource "aws_key_pair" "supermario_key" {
#   key_name   = "MySuperMarioKey"
#   public_key = data.aws_key_pair.mario_keypair.id
# }

# Resource block for ec2
resource "aws_instance" "supermario_server" {
  ami                  = data.aws_ami.ubuntu_latest.id
  instance_type        = var.instance_type
  key_name             = data.aws_key_pair.mario_keypair.key_name
  security_groups      = [aws_security_group.mario_access.name]
  iam_instance_profile = aws_iam_instance_profile.super_mario2_profile.name

  tags = {
    Name = var.name
  }
}

# Create s3 bucket to state terraform backend for our EKS resources
resource "aws_s3_bucket" "tfbucket" {
  bucket = "jones-shiny-tfbucket"

  tags = {
    Name        = "${var.name}-bucket"
    # Environment = "Dev"
  }
}

// Security group to allow SSH and HTTP access
resource "aws_security_group" "mario_access" {
  name        = "mario_access_sg"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// IAM Role with Administrator Access
resource "aws_iam_role" "super_mario2_role" {
  name = "super_mario2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

// Attach Administrator Access policy to the IAM Role
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.super_mario2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

// Instance profile to associate the role with EC2
resource "aws_iam_instance_profile" "super_mario2_profile" {
  name = "super_mario2_profile"
  role = aws_iam_role.super_mario2_role.name
}

