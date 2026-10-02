# 🚀 The 45-Day Zero to Senior DevOps / Cloud Engineer Roadmap

**Goal:** Pivot from a ₹3.2 LPA general IT role to a highly-specialized ₹10LPA - ₹18LPA Cloud/DevOps Engineer role.
**Commitment:** 4 to 5 hours daily (approx. 30 hours/week).
**Timeline:** 6 Weeks (~45 Days)

## 📌 Phase 1: Complete AWS & Terraform Foundation (Days 1 - 5)
*You are almost done with this!*
- **Day 1-2:** Complete Project 5 (S3 Static Hosting + CloudFront CDN + Route53).
- **Day 3-5:** Complete Project 6 (Docker basics + AWS ECS Fargate + ECR).
- **Interview Focus:** Be able to explain the 3-Tier architecture and why Terraform state locking is crucial.

## 📌 Phase 2: Multi-Cloud Expansion - Microsoft Azure (Days 6 - 15)
*Translating your AWS knowledge to Azure.*
- **Day 6-8:** Learn Azure core concepts (VNet, VMs, Blob Storage, Entra ID / Resource Groups).
- **Day 9-12:** Learn the `azurerm` Terraform provider.
- **Day 13-15:** Rebuild your AWS Project 4 (3-Tier App) entirely in Azure using Terraform. 
- **Interview Focus:** Comparing AWS and Azure services smoothly. "In AWS we use ASG, in Azure I used VMSS."

## 📌 Phase 3: Configuration & Containerization (Days 16 - 25)
*Moving inside the servers.*
- **Day 16-19:** Docker Deep Dive. Writing optimized `Dockerfiles`, multi-stage builds, and `docker-compose`.
- **Day 20-25:** Ansible. Writing Playbooks and Roles. 
  - *Project:* Use Terraform to create 3 empty VMs, then use Ansible to SSH in and install a web stack automatically.
- **Interview Focus:** Idempotency in Ansible. Why use Ansible vs Terraform UserData?

## 📌 Phase 4: Container Orchestration - Kubernetes (Days 26 - 37)
*The most heavily demanded skill in the market.*
- **Day 26-29:** K8s Architecture (Master, Worker nodes, Kubelet).
- **Day 30-33:** Core Objects (Pods, Deployments, Services, ConfigMaps, Secrets).
- **Day 34-37:** Deploy an EKS (AWS) or AKS (Azure) cluster using Terraform and deploy a microservice on it.
- **Interview Focus:** How does a web request reach a Pod? (Ingress -> Service -> Pod).

## 📌 Phase 5: CI/CD Pipelines & Automation (Days 38 - 45)
*Tying it all together.*
- **Day 38-41:** GitHub Actions. Write a pipeline that runs `terraform plan` on every Pull Request.
- **Day 42-45:** Jenkins. Set up a Jenkins server (using Terraform/Ansible) and create a pipeline to build a Docker image and push it to a registry.
- **Interview Focus:** Continuous Integration vs Continuous Deployment.

---

## 💼 Interview Preparation (Continuous - Every Weekend)
- **Resume Update:** Re-write your resume focusing on **ACHIEVEMENTS**, not just skills. (e.g., "Architected a highly-available 3-tier AWS infrastructure using Terraform, reducing manual provisioning time by 90%.")
- **Mock Interviews:** Speak aloud. Practice explaining your GitHub repositories as if you were presenting to a CTO.
