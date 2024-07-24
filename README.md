   # Netspi Terraform Assignment

This repository contains Terraform modules for setting up infrastructure components including VPC, roles, S3, EC2, and EFS. Below are the steps to run Terraform and deploy the infrastructure:
Able to upload object to S3  from the EC2 created, EFS is attached successfully with required access.

## Steps to Run Terraform

1. **Initialize Terraform:**
   ```bash
   terraform init

1. **Run a plan :**
   ```bash
   terraform plan -var-file nettest.tfvars

1. **Initialize Terraform:**
   ```bash
   terraform apply -var-file nettest.tfvars
