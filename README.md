# Super-Mario-Deployment-on-Kubernetes-using-terraform
Deploying One of the World's most popular game, Super Mario, on Amazon Elastic Kubernetes Service.
## Project Overview
Our childhood days were lot of fun because one game entertained us and this game is the famous **Super Mario**. Many of us can never forget this game, hence, we will deploy it on **Amazon EKS**.
###  Building Infrastructure Using terraform
1. Create a directory called **super_mario** and chnage directory into it. 
```
mkdir super_mario
cd super_mario
```
2. Clone the GitHub repo.
```
git clone https://github.com/Aakibgithuber/Deployment-of-super-Mario-on-Kubernetes-using-terraform.git
```
3. Change directory into Deployment-of-super-Mario-on-Kubernetes-using-terraform. First, list items in the directory.
```
ls
cd Deployment-of-super-Mario-on-Kubernetes-using-terraform/
```
4. List the objects in the directory and confirm `EKS-TF` is listed.
```
ls
cd  EKS-TF
```
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




















