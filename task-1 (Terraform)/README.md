# Task 1: Infrastructure Provisioning with AWS (Terraform)

This directory contains the Terraform configuration for setting up a basic AWS infrastructure to support a web application as required by the DevOps take-home test.

## Infrastructure Components

The Terraform configuration creates the following resources:

- A VPC with CIDR block 10.0.0.0/16
- A public subnet with CIDR block 10.0.1.0/24
- Internet Gateway attached to the VPC
- Route table with route to the Internet Gateway
- Security group allowing HTTP (port 80) and SSH (port 22) traffic
- EC2 instance running Amazon Linux 2 in the public subnet

## Files

- `main.tf` - Contains all resource definitions for the infrastructure

## Prerequisites

- Terraform v1.0 or later
- AWS CLI configured with appropriate credentials
- SSH key pair created in AWS (for EC2 access)

## Usage

1. Initialize the Terraform working directory:
   ```
   terraform init
   ```

2. Preview the changes to be applied:
   ```
   terraform plan
   ```

3. Apply the infrastructure changes:
   ```
   terraform apply
   ```

4. Access your EC2 instance using the public IP displayed in the outputs:
   ```
   ssh -i your-key.pem ec2-user@<public_ip>
   ```

5. When finished, destroy the infrastructure:
   ```
   terraform destroy
   ```

## Automation Benefits

This solution demonstrates infrastructure-as-code benefits including:
- Version-controlled infrastructure
- Reproducible deployments
- Consistent environments
- Self-documented architecture
- Easy cleanup and modification