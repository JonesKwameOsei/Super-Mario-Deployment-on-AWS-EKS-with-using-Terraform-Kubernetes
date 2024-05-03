# Super-Mario-Deployment-on-Kubernetes-using-terraform
Deploying One of the World's most popular game, Super Mario, on Amazon Elastic Kubernetes Service with **Terraform** and **Continuous Integration** and **Continuous Development** (CI/CD).
## Project Overview
Our childhood days were lot of fun because one game entertained us and this game is the famous **Super Mario**. Many of us can never forget this game, hence, we will deploy it on **Amazon EKS**. Terraform will be utilised to build the infrastructure in the AWS cloud. Then we will deploy the Terraform code with a CI/CD pipeline GitHub actions.  

### Create Identity Access Management (IAM) Role for Amazon Elastic Compute Cloud (EC2)
Cloud Engineers, Developers and DevOps Engineers need `IAM (Identity and Access Management)` roles for `EC2 (Elastic Compute Cloud)` instances for the following key reasons:

1. **Access Control**: IAM roles allow Cloud Engineers to manage and control the permissions and access rights of EC2 instances. This ensures that the instances can only perform authorized actions.

2. **Least Privilege**: IAM roles enable the implementation of the principle of least privilege, where each EC2 instance is granted only the minimum necessary permissions to perform its intended tasks, reducing the risk of unauthorised access or actions.

3. **Security and Compliance**: IAM roles are crucial for maintaining security and compliance standards, as they help enforce access policies and track user activities within the AWS environment.

4. **Dynamic Provisioning**: IAM roles allow for dynamic provisioning of permissions, enabling Cloud Engineers to easily manage and update the access rights of EC2 instances as requirements change.

5. **Cross-service Integration**: IAM roles facilitate the integration of EC2 instances with other AWS services, such as `S3 (Simple Storage Service)` or `DynamoDB`, by granting the necessary permissions for these services to interact with the EC2 instances.

In summary, IAM roles for EC2 instances are essential for access control, security, compliance, and integration, allowing Cloud and DevOps Engineers to effectively manage and secure their infrastructure in the AWS cloud. For this reason, we will create an IAM role for this project since we would need the EC2 to interact with other AWS services. <p>

1. In AWS Management Console, type `IAM` in the search bar.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/de91eac1-ed2d-430a-b63a-01e2b97c2268)<p>
2. Under **Access Management** on the left side of the dasboard, click `Roles`.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/bc2bb355-115a-4c2b-b367-03f2cf6e6c36)<p>
3. Next, click on `Create Roles` on the top right<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/4333a166-604a-4c20-8a9e-7503a229fed4)<p>
4. In the create role pane:
- under `Select trusted entity`, choose `AWS service`.
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/e85700de-f1e2-44c3-9719-a387dde2061c)<p>
- Under `Use case` (at the bottom), click the dropdown to select `EC2`.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/ef09e871-400c-4f2d-bba5-13b51bbd4e87)<p>
5. Click on `Next`to open the **Add permissions** pane.
6. Check the box before `AdministratorAccess` to add this permission to role created.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/d638eafd-0b62-4244-b351-8fa4cf0e7fed)<p>
7. Click `Next`.
8. Under `Role details`, enter a name for `Role name`.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/f930c64c-0c3e-43e0-ad5b-337e6b3f8698)<p>
At this point, you should see a `Trust Policy` populated in a **json** format that looks like this:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
```
9. Click on `Create`. A green notification bar appears on the Roles pane indicating `Role super_mario` created.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/b6013bbb-7623-465c-bb21-9035986a4dc8)<p>

10. Click on `View Role` to view the role created.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/1788fe69-3acd-4f69-9b1d-9d9d6f972589)<p>

###  Building Infrastructure Using terraform and GitHub Action Pipeline
Creating the `IAM Role` and other resources manually can be time consuming and might increase cost if a resource outside the free tier is not teared down (destroyed or deleted). To increase deployment productivity, properly manage infrastructure cost and enhance security in the cloud, using Infrastructure as Code tool like Terraform is benefial. Let us start building.
1. Clone the GitHub repo of project.
```
git clone git@github.com:JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform.git
```
2. Change directory into Super-Mario-Deployment-on-Kubernetes-using-terraform. 
```
code -a .      # This opens the current directory project folder without opening a new window
```
3. Create a directory called **EC2.tf** and change directory into it.
```
mkdir EC2.tf
cd EC2.tf
```

### Create Terraform configuration files.
- proider.tf:
```
vi provider.tf 
```
add this configurations:
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
```
- variables.tf: vi variables.tf with this code blocks:
```
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

```
- data.tf: We will add the code below to create this file. First, vi data.tf.
```
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
```
- main.tf: The resources file will be configured like this after **vi main.tf**.
```
resource "aws_key_pair" "my_keypair" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "supermario_server" {
  ami                  = data.aws_ami.ubuntu_latest.id
  instance_type        = var.instance_type
  // User data script to install Minikube, Docker, Terraform, and AWS CLI
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              sudo install minikube /usr/local/bin/
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              curl -o terraform.zip https://releases.hashicorp.com/terraform/1.2.11/terraform_1.2.11_linux_amd64.zip // Replace with the desired Terraform version
              unzip terraform.zip
              sudo mv terraform /usr/local/bin/
              EOF
  key_name             = aws_key_pair.my_keypair.key_name
  security_groups      = [aws_security_group.mario_access.name]
  iam_instance_profile = aws_iam_instance_profile.super_mario2_profile.name

  tags = {
    Name = var.name
  }
}

# Create s3 bucket
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
```
- output.tf: This configuration returns the IP Address of the EC2.
```
output "instance_ip_addr" {
  value = aws_instance.supermario_server.public_ip
}
```
### Create .github/workflows directory in the repo.
5. Edit the backend.tf file.
```
vi backend.tf
```
Add this configuray=tion to the file.
```
terraform {
  backend "s3" {
    bucket = "super_mariobucket"     # This should be a unique name
    key = "EKS/terraform.tfstate"
    region = "eu-west-1"             # region to deploy s3 bucket
}
}




















