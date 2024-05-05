![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/278c12de-c27a-42ff-8d35-7f0989b2b5a2)# Super-Mario-Deployment-on-Kubernetes-using-terraform
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

data "aws_key_pair" "mario_keypair" {
  key_name           = "MyMarioKeyPair"
}
```
- **main.tf**: The resources file will be configured like this after **vi main.tf**.
```
# Resource block for ec2
resource "aws_instance" "supermario_server" {
  ami                  = data.aws_ami.ubuntu_latest.id
  instance_type        = var.instance_type
  // User data script to install Minikube, Docker, Terraform, and AWS CLI
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -aG docker ubuntu
              curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              sudo install minikube /usr/local/bin/
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              curl -o terraform.zip https://releases.hashicorp.com/terraform/1.2.11/terraform_1.2.11_linux_amd64.zip // Replace with the desired Terraform version
              unzip terraform.zip
              sudo mv terraform /usr/local/bin/
              EOF
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
```
- output.tf: This configuration returns the IP Address of the EC2.
```
output "instance_ip_addr" {
  value = aws_instance.supermario_server.public_ip
}
```
### Create GitHub Actions Workflows Directory in the repo.
1. Create .github/workflows directory in the repo.
```
mkdir -p .github/workflows
```
2. Configure Git.
git config --global user.name <username>
git config --global user.email <user@example.com>

3. Initialise/reinitialise the repo
```
git init
```
5.  Create hub: Usually for a new repo. No need to run this command if the repo was cloned.
```
hub create
```
The command `hub create` is used in the context of the **GitHub** **Hub command-line** tool. This tool provides a convenient way to interact with **GitHub** from the command line.

The `hub create` command is used to create a new GitHub repository directly from the command line, without needing to go to the GitHub website and manually create a new repository there.<p>

When you run `hub create`, it will:

- Prompt you to enter a name for the new repository.
- Optionally, it can also prompt you to enter a description for the repository.
- It will then create the new repository on GitHub using the provided name and description.

After running `hub create`, we can then `cd` into the new repository directory and start working on the project, adding files, making commits, and pushing changes to the newly created GitHub repository.<p>

This command can save time and streamline our GitHub workflow by allowing us to create new repositories directly from the command line, without having to switch contexts to the GitHub website.
6. Create required GitHub secrets. To create the secret in GitHub:
- In the GiHub repo, click on **Settings**
- Then click on the **DropDown** next to **Secrets and Variables**<p>
![image](https://github.com/JonesKwameOsei/Automate-Azure-SQL-Database-Deployment-with-Terraform/assets/81886509/1032987c-9041-4ee1-ab38-92e33b34e858)<p>
- Next, click on **Actions**.<p>
![image](https://github.com/JonesKwameOsei/Automate-Azure-SQL-Database-Deployment-with-Terraform/assets/81886509/0ce6d04a-9acd-4449-bbe1-5cbc3e2a790b)<p>
- Click on **New repository secret** <p>
![image](https://github.com/JonesKwameOsei/Automate-Azure-SQL-Database-Deployment-with-Terraform/assets/81886509/4c20a15f-bd1c-48bd-a040-6c11166da840)<p>
- We will create 2 secrets for **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY**. Each will look like this:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/bf5b9c52-c197-4d3c-a9c8-6bf764c514b0)<p>

![image](https://github.com/JonesKwameOsei/Automate-Azure-SQL-Database-Deployment-with-Terraform/assets/81886509/6714b39f-1a07-4865-a091-7b99b200546b)<p>
![image](https://github.com/JonesKwameOsei/Automate-Azure-SQL-Database-Deployment-with-Terraform/assets/81886509/1222176c-d42c-4d92-8394-53bd8030325e)<p>

### Code Deployment with GitHub Actions
We will need a **GitHub Action Workflows** to run the Terraform configurations in a pipeline. The workflows will be configured in a file called `action.yaml`:
```
name: Terraform Deploy AWS Infrastructure

# Controls when the workflow will run
on:
  workflow_dispatch:
    inputs:
      terraform_action:
        type: choice
        description: Select Terraform action
        options:
        - apply
        - destroy
        required: true
  push:
    branches:
      - main

jobs:
  deploy:
    name: Deploy AWS EC2 and S3 bucket
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: EC2

    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    steps:
    - name: Checkout repo
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2

    - name: Terraform Init
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.3
        tf_actions_subcommand: 'init'
        tf_actions_working_dir: '.'
        tf_actions_comment: true

    - name: Terraform plan
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.3
        tf_actions_subcommand: 'plan'
        tf_actions_working_dir: '.'
        tf_actions_comment: true
      
    - name: Terraform apply
      if: ${{ github.event.inputs.terraform_action == 'apply' }}
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.3
        tf_actions_subcommand: ${{ github.event.inputs.terraform_action }}
        tf_actions_working_dir: '.'
        tf_actions_comment: true
        args: '-auto-approve'
    
    - name: Terraform destroy
      if: ${{ github.event.inputs.terraform_action == 'destroy' }}
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.3
        tf_actions_subcommand: ${{ github.event.inputs.terraform_action }}
        tf_actions_working_dir: '.'
        tf_actions_comment: true
        args: '-auto-approve'
```
The workflow configured is explained below:
1. **Checkout the repository**: Checkout the code from the repository.
2. **Setup Terraform**: Install the necessary Terraform version and Azure provider.
3. **Initialize Terraform**: Run `terraform init` to initialize the working directory.
4. **Validate Terraform configuration**: Run `terraform validate` to check the syntax and validity of the Terraform configuration.
5. **Apply Terraform changes**: Run `terraform apply` to deploy the infrastructure changes.<p>
Before we push the changes to activate the pipeline actions, let us confirm there are no resources in the AWS cloud destination, `eu-west-1: Ireland`:<p>
No EC2 Instance resource:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/c02bbab4-69e3-462a-9307-9fc4833521de)<p>
No S3 Bucket:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/38381fed-6024-4222-8b83-b8f579a7c26f)<p>


There is one `IAM Role` named **super_mario:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/eb1425e5-cebf-470e-a362-e5706421f07f)<p>

### Push Changes to GitHub to activate Github Action
The GitHub Actions workflow is triggered on push events to the main branch, ensuring that any changes to the Terraform configuration are automatically deployed to the Azure environment. It is recommended to push the changes from a different branch, then merge it with the main branch by making a **pull request**.
```
git checkout -b deployAWSInfra        # Creates a new braanch and switch into it from the main

git add .                               # Adds the changes to the repo

git status                              # Lists the changes to be commited or pushed to the repo

git commit -m "commit message"          # States the reason for the push or changes

git push origin deployAWSInfra          # pushes the changes to the repo from the new branch
```
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/883b58df-3719-4083-b19c-03ab03da579a)<p>
We need to create the pull request to merge the changes to the main branch to trigger the actions.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/dc570eb8-7f08-4de3-bd5a-df2984ad90ac)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/d70959ff-88dc-4689-985b-c1423ab05d75)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/1aa35062-6b61-4a54-a8f2-bc1381cc3f43)<p>
Now we will click on the green button **Create pull request**. <p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/b59319ba-a05a-4d69-be28-ec4aa4c6d21f)<p>
To **Merge** the changes to the **main** branch, we will click on the green button **Merge pull request** and then **Confirm merge**. Confirming the nerge will trigger the actions.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/6760ee8c-6f08-4549-8efa-f61bd20eabae)<p>
Pull request successfully merged and Github actions pipeline has run successfully.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/4f77ace6-dcf5-45e6-951d-f18d271445f7)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/e003976d-d774-4e34-b224-c01f23ae3e3d)<p>

![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/0e764595-aeb7-47b7-917f-f93980f26324)<p>
### Confirm Deployments on AWS Console
1. EC2 Instance named Supermario_server created with the following details:
- Public IP Address: 54.170.82.23
- Instance type: t2.micro
- Key Pair: MyMarioKeyPair<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/3ccb63f9-b873-43cc-8723-be2b6727a0ff)<p>
- IAM Role: super_mario2.<p>
**N/B**: This IAM role, `super-mario`, attached to the EC2 is different from the one we created in the IAM console, `super-mario`. Evidence is below:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/c3f7d028-c9ed-437f-b5f2-f38c2c4ecca6)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/61b44a69-8a9d-4b3c-b640-f2b4cbe07a2d)<p>

2. Amazon S3 Bucket created with these deatials:
- Bucket name: jones-shiny-tfbucket
- Europe (Ireland) eu-west-1<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/1bf568ed-4248-4fca-b7df-82dac302708f)<p>

### Test Connection to EC2 Instance Remotely
To connect to an EC2 (Elastic Compute Cloud) instance, we can follow these steps.
1. Connect to the EC2 instance with ` EC2 Instance Connect`:
   - Click on the `Connect` button at the top of the instance pane after the ↻ refresh button.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/4a0eb513-a142-4c52-b8e7-82f8ea9715f7)<p>
    - Next, ensure you are in the `EC2 Instance Connect` or click on `EC2 Instance Connect` tab.
    - At the bottom, click on `Connect`.
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/40516b91-2409-4c8c-a70f-89e3cea5b259)<p>
Successfully connected to the instance through EC2 Instance Connect:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/d3ca9e4f-6444-4f74-bd4a-52dd97b12021)<p>

2. SSH connect
Here's an example of how to connect using SSH from a Linux or macOS terminal:
```
ssh -i ~/.ssh/id_rsa ubuntu@54.170.82.23
```
3. Verify the connection:
   - After executing the SSH command, you should be logged in to your EC2 instance. You can now run commands and perform tasks on the instance.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/7db06ca1-a8c5-484b-9764-82bb5cb3ea33)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/2e697003-db77-4b07-a97b-bd0e48bfa1df) <p>

###  Setup Docker ,Terraform ,aws cli , and Kubectl
Having SSH into the EC2 instance, we will set up `Docker`, `Terraform` ,`Aws cli` , and `Kubectl`.<p>
1. Setup Docker 
```
# Update the apt package and  install repository addition dependencies
sudo apt update and upgrade -y
sudo apt install docker.io
sudo usermod -aG docker instanceusername # Replace with your username e.g ‘ubuntu’
sudo newgrp docker
# Check the version of docker installed 
docker --version
```
2. Install Terraform
```
# Update the apt package and  install repository addition dependencies
sudo apt update -y
sudo apt install  software-properties-common gnupg2 curl
# import repository GPG key
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
# add Hashicorp repository to the Ubuntu system
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# install terraform on Ubuntu Linux system
sudo apt install terraform
# Check the version of terraform installed 
terraform --version
```
3. Install AWS CLI
```
# Download installation zip file
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# Unzip the zip file downloaded
sudo unzip awscliv2.zip
# Install the cli
sudo ./aws/install
# Check the version running
aws --version
```
4. Setup kubectl
```
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
### Create Terraform configurations for EKS
The following terraform configurations create a Terraform backend in the s3 bucket we created earlier, create IAM role for Amazon EKS, and fetch vpc data to be called in the EKS resource block. 
1. main.tf
```
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_mario" {
  name               = "eks-cluster-cloud"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "mario-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_mario.name
}

#get vpc data
data "aws_vpc" "default" {
  default = true
}
#get public subnets for cluster
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
#cluster provision
resource "aws_eks_cluster" "mario_cluster" {
  name     = "EKS_CLOUD"
  role_arn = aws_iam_role.eks_mario.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.mario-AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "supermario" {
  name = "eks-node-group-cloud"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "kubemario-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.supermario.name
}

resource "aws_iam_role_policy_attachment" "mymario-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.supermario.name
}

resource "aws_iam_role_policy_attachment" "mysupermario-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.supermario.name
}

#create node group
resource "aws_eks_node_group" "sm-grp" {
  cluster_name    = aws_eks_cluster.mario_cluster.name
  node_group_name = "Node-cloud"
  node_role_arn   = aws_iam_role.supermario.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t2.medium"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.kubemario-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.mymario-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.mysupermario-AmazonEC2ContainerRegistryReadOnly,
  ]
}
```
2. providers.tf
```
terraform {
  terraform {
  backend "s3" {
    bucket = "jones-shiny-tfbucket" # The S3 bucket bucket we created
    key    = "EKS/terraform.tfstate"
    region = "eu-west-1"
  }
}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}
```
Deploy Code
1. Initialise the repo
```
terraform init
```
 `terraform init`:
   - This command is used to initialize a Terraform working directory.
   - It downloads and installs the necessary provider plugins based on the configuration files.
   - It also creates a `.terraform` directory in the current working directory to store the downloaded plugins and other metadata.
   - This step is required before running any other Terraform commands.
   - It prepares the directory for subsequent Terraform operations.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/2321b802-aac2-4e63-b529-d01e3ade319f)<p>

2. Inspect configuration files for validation.
```
terraform validate
```
`terraform validate`:
- This command is used to check the syntax and validity of the Terraform configuration files.
- It ensures that the configuration is well-formed and does not contain any errors.
- It verifies the structure of the configuration, including resource definitions, input variables, and outputs.
- This command helps catch potential issues before running other Terraform commands, like terraform plan or terraform apply.
- Validating the configuration is an essential first step in the Terraform workflow to ensure that the infrastructure will be provisioned correctly.<p>

![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/82f0b67d-7e6d-4f7b-8403-627ed303d641)<p>

3. Plan the deployment.
```
terraform plan
```
`terraform plan`:
   - This command is used to create an execution plan for the infrastructure changes.
   - It analyzes the current state of the infrastructure and the desired state defined in the configuration files.
   - It identifies the resources that need to be created, modified, or destroyed.
   - The plan is presented as a set of changes that will be applied when `terraform apply` is executed.
   - This allows you to review the changes before actually applying them to your infrastructure.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/1e95558a-5d0d-4225-aee9-50ecae931bc1)<p>

4. Deploy Amazon EKS Infrastructure
```
terraform apply --auto-approve
```
`terraform apply --auto-approve`:
   - This command is used to apply the changes identified by the `terraform plan` command.
   - The `--auto-approve` flag skips the prompt for user confirmation, allowing the command to run without manual intervention.
   - It provisions, updates, or destroys the resources according to the execution plan.
   - The changes are applied to the actual infrastructure, bringing it in line with the desired state.
   - This command is typically used in automated deployment workflows or when you're confident about the changes.
Terraform apply executed successfully.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/53ff4bac-6047-4c53-a766-a64e87cf9f62)<p>
Let us verify this from the AWS Console.<p>
EKS is running on EC2 with the right configurations.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/684b3c12-71e8-4fc7-8345-43b2a39c49d1)
The Kubernetes Cluster, `EKS_Cloud`, is successfully created by Terraform in Amazon Kubernetes Services.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/63eb2fa5-9eb6-435e-9b34-36c9d76e74f2)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/aa368fbd-ab54-4827-b9e6-4b7cb12bbcea)<p>
Tfstate file stored in S3 bucket:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/246a7e5f-6aed-4bdf-b3cc-b6e6e938cdb0)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/ae1a88b0-40eb-4def-b459-6d26d9186605)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/cd4bcbc6-b880-4ae1-aef0-beb033cacf74)<p>

![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/628a5032-81c0-4d15-916b-5108fcfc7198)<p>
5. Update the configurations of AWS EKS
```
aws eks update-kubeconfig --name EKS_CLOUD --region eu-west-1
```
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/26d61ce9-3c30-4fac-9c8c-54b353be8901)<p>

The command "aws eks update-kubeconfig --name EKS_CLOUD --region eu-west-1" is used to update the kubeconfig file with the necessary configuration to manage an Amazon EKS cluster named "EKS_CLOUD" in the "eu-west-1" region. This command is typically used to configure the Kubernetes command-line tool (kubectl) to communicate with the specified Amazon EKS cluster.<p>

### Creation of deployment and service for EKS
1. Create a directory named kube-mario with these configurations to deploy `super mario` game and create service for the app.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mario-deployment
spec:
  replicas: 2  # You can adjust the number of replicas as needed
  selector:
    matchLabels:
      app: mario
  template:
    metadata:
      labels:
        app: mario
    spec:
      containers:
      - name: mario-container
        image: sevenajay/mario:latest 
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: mario-service
spec:
  type: LoadBalancer
  selector:
    app: mario
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mario-ingress
  namespace: super-mario
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
               service:
                 name: mario-service
                 port:
                   number: 80
```
Create namespace called super-mario namespace.yaml
```
apiVersion: v1
kind: Namespace
metadata:
  name: super-mario
```
2.Create the namespace
```
kubectl apply -f namespace.yaml 

```
3. Create the deployment
```
kubectl apply -f deployment.yaml 
````
Kubernetes have deployed the mario app, created the service, ingress in the namespace, `super-mario`. <p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/0e551179-9fd7-4750-94d0-a9920d2296d6)

### Test App
1. Let us view all the deployment components
```
kubectl get all
```
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/9655b5d2-9c4d-4501-ba8a-a990ad6f380e)<p>
2. To get more details about the service loadbalancer, we will run:
```
kubectl describe service mario-service
```
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/0cbf3dea-a67b-482f-8779-508ed9a98fe1)<p>
copy the load balancer ingress and paste it on browser and your game is running.
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/9afdd492-7942-465f-8a61-1c25674ee7a4)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/0c83b6b2-cd74-409c-941f-e024a6501295)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/faa41179-60ff-4964-9f34-310f2619d2b4)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/92586c33-788c-4060-89b6-07746cb5198b)<P>

Play and enjoy exploring the Super Mario game, but be mindful of the AWS bill and account security. Avoid actions that could inadvertently or intentionally destroy your resources or compromise your AWS account. I enjoyed playing the and remembered the good old days as a kid!

## Destroy all the Insrastructure
The steps below remove all the infrastructure built with `Terraform`, `Kubernetes` and EC2. 
1. Delete Kubernetes Resources
```
kubectl delete service mario-service
kubectl delete deployment mario-deployment
kubectl delete namespace super-mario
```
Reousrces destroyed.<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/84271910-9d6a-4389-b976-64c077572f18)<p>
2. Drestory EKS Infrastructure
```
cd EKS-TF
terraform destroy --auto-approve
```
Eight(8) EKS eources destroyed:<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/bf03517e-9aa2-4736-abc0-839748497b2e)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/c123f561-4923-4e04-b7e4-4ca4fd4ba0e6)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/cfb03a23-eafd-4806-bc4a-6e0cee8cf0ec)<p>
3. Destroy EC2 Instance created with the GitHub pipeline actions. 
We will Click on the work flow drop doen and choose `Destroy`. Then click run workflow. <p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/4ff8aebc-d70e-4243-807f-cd220faa686f)<p>
![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/79d37366-e225-48a8-a41b-d7d304fa219e)


![image](https://github.com/JonesKwameOsei/Super-Mario-Deployment-on-Kubernetes-using-terraform/assets/81886509/3fac5fde-0a31-48bf-b6fa-c63c625e6f6a)<p>

















