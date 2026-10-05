# 🐳 Project 6: Containerized Microservices with AWS ECS (Fargate) & ALB

A production-grade, highly-available container orchestration architecture deployed on AWS using Terraform. The application runs Docker containers on serverless **AWS ECS Fargate**, load-balanced across multiple Availability Zones using an **Application Load Balancer (ALB)**, with centralized logging via **AWS CloudWatch** and strict least-privilege IAM execution roles.

---

## 🏗️ Architecture Diagram

```
[ Internet Users ]
       │ (HTTP: Port 80)
       ▼
[ Application Load Balancer ]  <--- (Public Subnets across AZs)
       │
       │ (HTTP: Port 80 via Target Type "IP")
       ▼
[ Chained Security Group Firewall ]
       │
       ├──► [ ECS Task 1 (Fargate) ] (Subnet A) ──► Streams Logs to CloudWatch
       └──► [ ECS Task 2 (Fargate) ] (Subnet B) ──► Streams Logs to CloudWatch
```

---

## 🔑 Key Architectural Highlights

- **Serverless Containers (AWS Fargate):** Zero EC2 virtual machines to provision, patch, or maintain. AWS manages the underlying compute infrastructure.
- **High Availability & Auto-Healing:** The ECS Service maintains `desired_count = 2` tasks distributed across multiple availability zones. If any task becomes unhealthy or crashes, ECS automatically terminates and replaces it.
- **Target Type "IP" Routing:** Leverages `awsvpc` network mode, assigning a dedicated Elastic Network Interface (ENI) and private VPC IP to each task, directly registered into the ALB target group.
- **Chained Security Groups:** The ECS Tasks security group permits inbound traffic on port 80 **strictly** from the ALB security group ID, blocking direct internet exposure.
- **Observability & Logging:** Integrated with AWS CloudWatch Logs (`/ecs/ecs-fargate-microservice`) with a 7-day retention policy to capture standard output/errors without incurring runaway storage costs. Enabled **Container Insights** on the ECS cluster for task-level diagnostic monitoring.
- **Least-Privilege IAM Execution:** Dedicated ECS task execution role granting the background ECS agent permissions to pull images and stream logs.

---

## 📁 File Structure

```
project-6/
├── provider.tf        # AWS Provider & S3 Remote State Backend
├── variables.tf       # Region, container image, ports, desired task count
├── network_data.tf    # Dynamic VPC and Subnet data lookups
├── security_group.tf  # ALB and Chained ECS Task security groups
├── iam.tf             # ECS Task Execution Role & Managed Policy attachment
├── alb.tf             # Application Load Balancer, IP Target Group, & Listener
├── ecs.tf             # CloudWatch Log Group, ECS Cluster, Task Definition, & Service
└── outputs.tf         # Public ALB DNS URL, Cluster/Service names, Log Group
```

---

## 🚀 How to Run

```bash
# 1. Initialize Terraform remote state
terraform init

# 2. Preview deployment plan (11 resources)
terraform plan

# 3. Deploy containerized infrastructure
terraform apply -auto-approve
```

---

## 🧪 Verification

1. **Access Application:** Open `alb_url` output in your browser. Confirms load balancer routing to the healthy container tasks.
2. **Load Balancing Test:** Refresh the browser multiple times. Observe the server address toggling between the private task IPs.
3. **CloudWatch Logs:** Check AWS CloudWatch Log Group `/ecs/ecs-fargate-microservice` to verify live access and error logs.

---

## 🧹 Teardown

To avoid ongoing AWS charges (ALB and Fargate compute):

```bash
terraform destroy -auto-approve
```
