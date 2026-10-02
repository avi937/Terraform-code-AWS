# ☁️ AWS Terraform Infrastructure Portfolio

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-Provider_5.0+-FF9900?logo=amazon-aws&logoColor=white)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![Architecture](https://img.shields.io/badge/Architecture-Modular_Multi--Project-blue?logo=awslambda&logoColor=white)](#)

A structured, production-ready collection of AWS Infrastructure as Code (IaC) projects built with Terraform. Each project is fully isolated with dedicated S3 remote state tracking, modular configurations, and automated bootstrapping.

---

## 📂 Projects Directory

| # | Project | Description | Status |
| :---: | :--- | :--- | :---: |
| **01** | [**Project 1: Automated EC2 Web Server**](./project-1/) | Dynamic AMI lookup, automated RSA key generation, custom security group, and zero-touch Nginx bootstrap via UserData. | **Completed ✅** |
| **02** | [**Project 2: Production Custom Multi-AZ VPC**](./project-2/) | Fully isolated network with Public/Private subnets across 2 AZs, Internet Gateway, and NAT Gateway. | **Completed ✅** |
| **03** | [**Project 3: High Availability & Auto Scaling**](./project-3/) | Application Load Balancer (ALB) + Auto Scaling Group (ASG) across multiple Availability Zones with dynamic traffic-based target tracking. | **Completed ✅** |
| **04** | [**Project 4: Enterprise 3-Tier Web App**](./project-4/) | Public ALB &rarr; Private EC2 ASG Web Tier &rarr; Private RDS MySQL with Secrets Manager, dynamic credential injection, and zero-downtime rotation. | **Completed ✅** |
| **05** | [**Project 5: Static Site & CloudFront CDN**](./project-5/) | Serverless S3 static hosting + CloudFront global CDN + Origin Access Control (OAC) + automated asset deployment with `etag` hashing. | **Completed ✅** |
| **06** | [**Project 6: Containerized Microservices**](./project-6/) | Docker container orchestration on AWS ECS (Fargate) with ALB and ECR. | *Planned 📅* |

---

## 🛠️ Global Prerequisites

Before running any project:
1. **Terraform CLI** (>= 1.5.0): `terraform -version`
2. **AWS CLI** (v2) configured with active credentials:
   ```bash
   aws configure
   aws sts get-caller-identity
   ```
3. **S3 State Storage Bucket**: Created in your AWS account (e.g. `terraform-file-0025-12`).

---

## 🚀 How to Run Any Project

Each project directory is completely self-contained. To run any project:

```bash
# 1. Navigate into the specific project folder (e.g. project-5)
cd project-5

# 2. Initialize Terraform (connects to its dedicated S3 remote state)
terraform init

# 3. Preview execution plan
terraform plan

# 4. Deploy resources
terraform apply -auto-approve
```

To teardown and avoid AWS billing:
```bash
terraform destroy -auto-approve
```

---

## 🔒 Security Best Practices

- **Zero Hardcoded Secrets**: Sensitive variables use `.tfvars` which are strictly excluded from version control via `.gitignore`.
- **Dynamic Secrets Management**: Passwords generated with high entropy via Terraform `random_password` and stored directly into AWS Secrets Manager.
- **Isolated State**: Each project maintains its own isolated S3 state key (`dev/terraform.tfstate`, `project-2/terraform.tfstate`, `project-3/terraform.tfstate`, `project-4/terraform.tfstate`, `project-5/terraform.tfstate`), preventing cross-project state corruption.
- **Private Key Safeguards**: Generated private keys (`*.pem`, `*.key`) are automatically excluded from Git commits.
