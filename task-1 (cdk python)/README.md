# Task 1: Infrastructure Provisioning with AWS (CDK Python)

This directory contains the AWS CDK Python implementation for setting up a basic AWS infrastructure to support a web application as required by the DevOps take-home test.

## Infrastructure Components

The CDK stack creates the following resources:

- A VPC with public and private subnets
- Internet Gateway for public internet access
- Security group allowing HTTP (port 80) and SSH (port 22) traffic
- EC2 instance running Amazon Linux 2 in a public subnet
- IAM role and profile for EC2 with necessary permissions

## Files

- `app.py` - Entry point for the CDK application
- `task1_stack.py` - Contains the stack definition with all resources
- `requirements.txt` - Python dependencies for the CDK application
- `cdk.json` - CDK configuration file

## Prerequisites

- Python 3.8 or newer
- AWS CLI configured with appropriate credentials
- AWS CDK Toolkit installed (`npm install -g aws-cdk`)
- SSH key pair created in AWS (for EC2 access)

## Setup and Deployment

1. Create and activate a virtual environment:
   ```
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install required dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Bootstrap the CDK environment (first-time only):
   ```
   cdk bootstrap
   ```

4. Deploy the stack:
   ```
   cdk deploy
   ```

5. Access your EC2 instance using the public IP displayed in the outputs:
   ```
   ssh -i your-key.pem ec2-user@<public_ip>
   ```

6. When finished, destroy the infrastructure:
   ```
   cdk destroy
   ```

## CDK Benefits

This solution demonstrates AWS CDK benefits including:
- Using high-level programming language (Python) for infrastructure definition
- Leveraging built-in AWS best practices through L2 constructs
- Type checking and IDE auto-completion for AWS resources
- Simplified resource provisioning with sensible defaults
- Native CloudFormation integration