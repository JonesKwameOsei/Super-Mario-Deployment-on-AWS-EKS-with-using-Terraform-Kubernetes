// #!/bin/bash

// # Update package lists and install necessary dependencies
// sudo apt-get update
// sudo apt-get install -y docker.io

// # Start Docker service and add ec2-user to the docker group
// sudo systemctl start docker
// sudo usermod -aG docker ubuntu

// # install curl
// sudo apt install curl -y
// # Install Minikube
// curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
// && sudo install minikube /usr/local/bin/

// # Install AWS CLI
// curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
// && unzip awscliv2.zip \
// && sudo ./aws/install

// # Install Terraform
// curl -o terraform.zip https://releases.hashicorp.com/terraform/1.2.11/terraform_1.2.11_linux_amd64.zip \
// && unzip terraform.zip \
// && sudo mv terraform /usr/local/bin/
