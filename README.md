# Terraform AWS Infrastructure

This repository contains Terraform code for managing and provisioning AWS cloud infrastructure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.5.0)
- [AWS CLI](https://aws.amazon.com/cli/) (v2) configured with valid IAM credentials
- [Git](https://git-scm.com/)

## Quick Start

### 1. AWS Credentials Configuration
Ensure your AWS credentials are configured locally:
```bash
aws configure
```

Verify your identity:
```bash
aws sts get-caller-identity
```

### 2. Initialize Terraform
Initialize the working directory to download the required AWS provider plugins:
```bash
terraform init
```

### 3. Plan & Validate
Preview the execution plan to see what resources will be created, modified, or destroyed:
```bash
terraform plan
```

### 4. Apply Changes
Provision the AWS infrastructure:
```bash
terraform apply
```

### 5. Cleanup
To destroy all provisioned resources:
```bash
terraform destroy
```

## Project Structure
```text
.
├── README.md
├── main.tf          # Core infrastructure resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── provider.tf      # AWS provider and Terraform backend configurations
```
