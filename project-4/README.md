# 🏛️ Project 4: Enterprise 3-Tier Web Architecture with Amazon RDS & DevSecOps Secrets Management

## 1. Project Overview & Architecture

This project implements a production-grade **3-Tier Enterprise Web Architecture** on AWS using Terraform. It provides complete network isolation, automated scaling, high availability, and bank-grade secrets management.

### Architectural Diagram:

```text
[ Public Internet Users ]
           │
           ▼  (HTTP / Port 80)
┌─────────────────────────────────────────────────────────────┐
│  Tier 1: Web / Presentation Tier (Public)                   │
│  • Public Application Load Balancer (ALB)                   │
│  • Deployed across Multi-AZ Public Subnets (Mumbai 1a, 1b)  │
│  • Security Group: Open to 0.0.0.0/0 on Port 80             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼  (Private Traffic / Port 80)
┌─────────────────────────────────────────────────────────────┐
│  Tier 2: Application / Logic Tier (Private)                 │
│  • Auto Scaling EC2 Fleet running Web Application           │
│  • Deployed across Multi-AZ Subnets                         │
│  • Security Group: Accepts Port 80 ONLY from ALB SG         │
│  • Zero direct inbound public internet access               │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼  (MySQL / Port 3306)
┌─────────────────────────────────────────────────────────────┐
│  Tier 3: Database / Data Tier (Deep Private)                │
│  • Amazon RDS (MySQL 8.0) Engine                            │
│  • Deployed across DB Subnet Group (Multi-AZ)               │
│  • Security Group: Accepts Port 3306 ONLY from EC2 SG       │
│  • ZERO public internet access                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Infrastructure Files Implemented

### 1. `provider.tf`
* **Isolated State:** Configures the S3 backend with key `project-4/terraform.tfstate` in bucket `terraform-file-0025-12`. This guarantees that changes to Project 4 will never interfere with Projects 1, 2, or 3.
* **Dual Providers:** Configures both `aws` and `random` providers.
* **Default Tags:** Automatically stamps all infrastructure resources with `Project = "Project-4-3Tier-App"`.

### 2. `variables.tf` & `terraform.tfvars`
* **Compute Tier:** `t3.micro` (chosen over legacy `t2.micro` due to full hardware support across all Mumbai data centers: `ap-south-1a`, `1b`, and `1c`).
* **Database Tier:** `db.t3.micro` with 20 GB gp3 storage (100% AWS Free Tier eligible).
* **Security Decision:** **No `db_password` variable exists.** Storing passwords in `.tf` or `.tfvars` files is an anti-pattern. Credentials are generated dynamically.

### 3. `network_data.tf`
* Queries `data.aws_vpc.default` and `data.aws_subnets.default`.
* **RDS High Availability Rule:** AWS RDS mandates that database subnet groups must span **at least two distinct Availability Zones** for automated failover. Fetching all Mumbai default subnets satisfies this requirement.

### 4. `secrets.tf` (DevSecOps Core)
* **`random_password.db_password`:** Generates a 16-character high-entropy password.
* **`aws_secretsmanager_secret`:** The encrypted vault container in AWS.
* **`aws_secretsmanager_secret_version`:** The actual JSON credential payload stored inside the vault.

---

## 3. Deep Dive: Password Generation & Secrets Management

### A. Terraform Password Configuration
```hcl
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
```
* **Character Composition:** Includes uppercase (`A-Z`), lowercase (`a-z`), numbers (`0-9`), and safe symbols.
* **Why `override_special` is required:** Default special characters include `/`, `@`, `"`, `'`, and space. If a password contains an `@` or `/`, database connection URLs (e.g. `mysql://user:p@ss/word@host:3306/db`) will break. `override_special` restricts symbols strictly to URL-safe characters.
* **Why `.result` instead of `.id`:** In the `random` provider, `.id` is an internal tracking hash. The `.result` attribute contains the actual raw generated plaintext password.

### B. The Vault vs. The Document
* **`aws_secretsmanager_secret` (The Safe):** Holds metadata, access policies, encryption keys, and tags. When created, it is completely empty.
* **`recovery_window_in_days = 0`:** In AWS, deleted secrets enter a 30-day soft-delete state by default. Setting this to `0` forces immediate permanent deletion upon `terraform destroy`, allowing quick redeployments without name collision errors.
* **`aws_secretsmanager_secret_version` (The Paper in the Safe):** Holds the actual secret string formatted as clean JSON.

---

## 4. Zero-Downtime Secret Rotation Mechanics

### The "Chicken-and-Egg" Problem
Traditional password updates cause downtime:
1. Changing the database password first causes the web app to crash immediately with `Access Denied`.
2. Changing the application configuration first causes it to crash because the database has not updated yet.

### Staging Labels
AWS Secrets Manager uses three dynamic internal labels to coordinate updates:

| Staging Label | Definition |
| :--- | :--- |
| **`AWSCURRENT`** | The active password currently serving live production traffic. |
| **`AWSPENDING`** | The candidate new password currently undergoing automated connectivity tests. |
| **`AWSPREVIOUS`** | The emergency backup password preserved for instant rollback. |

### Application Access Pattern
Applications call:
```bash
aws secretsmanager get-secret-value --secret-id "three-tier-app-db-credentials"
```
Applications never specify a version number (`v1`, `v2`, etc.). AWS automatically delivers whichever version carries the **`AWSCURRENT`** label.

### The 4-Step Rotation Handshake:
1. **Generate:** AWS generates a new password and marks it `AWSPENDING`. Live traffic is unaffected and continues using `AWSCURRENT`.
2. **Update DB:** AWS connects to the database engine and updates the user credentials to accept the new password.
3. **Test:** AWS tests connecting to MySQL with the `AWSPENDING` credentials.
   * *If the test fails:* Rotation aborts immediately. `AWSCURRENT` remains untouched. **Zero customer downtime.**
   * *If the test succeeds:* Proceed to Step 4.
4. **Promote (The Switch):** AWS swaps labels instantaneously:
   * The old `AWSCURRENT` becomes `AWSPREVIOUS`.
   * `AWSPENDING` becomes the new `AWSCURRENT`.

---

## 5. Failure Scenarios & Disaster Recovery ("Break-Glass")

### Scenario 1: New password fails during rotation test
* **Automatic safety:** AWS immediately cancels rotation and triggers a CloudWatch error alarm.
* The live application never experiences downtime because it remained connected using `AWSCURRENT`.

### Scenario 2: New password passes test, switches, but app fails afterwards
* Secrets Manager does not inspect custom application logic.
* **Instant Rollback:** Because AWS preserved the old working password as `AWSPREVIOUS`, you can flip `AWSCURRENT` back to `AWSPREVIOUS` with a single CLI command or automated CloudWatch alarm without needing to reset the database.
* **Enterprise Two-User Strategy:** High-traffic platforms (Netflix, financial institutions) create two database users: `user_a` and `user_b`. When rotating, they alternate users. Both users remain valid in MySQL simultaneously for a 24-hour grace period, ensuring that active queries are never terminated mid-execution.

### Scenario 3: Total Lockout (Both new and old passwords are corrupted)
In AWS RDS, **you can never be permanently locked out**:
1. **Hypervisor Master Password Reset:**
   * AWS manages the underlying hypervisor. You can reset the master password directly via the AWS Console or AWS CLI (`aws rds modify-db-instance --master-user-password ... --apply-immediately`) without providing the old password.
2. **Point-in-Time Recovery (PITR):**
   * Continuous transaction logs are uploaded to S3 every 5 minutes. You can rewind the entire database to any specific minute within your backup retention window.
3. **IAM Database Authentication (The Passwordless Future):**
   * Modern architectures eliminate static passwords entirely. Instances assume an IAM role and authenticate using short-lived 15-minute temporary AWS security tokens.


---

## 6. 🏆 Bonus Deep Dive: Concurrency & State Locking (The Alice & Bob Disaster)

### The Scenario: Concurrent Execution Without Locking
Imagine two engineers, **Alice** and **Bob**, working on the same AWS infrastructure without state locking enabled.
* Current S3 State: `[VPC, Subnets]`

### The Catastrophic Timeline:
1. **10:00:00 AM:** Alice runs `terraform apply` to create an **Application Load Balancer (ALB)**. Her computer downloads the current state: `[VPC, Subnets]`.
2. **10:00:02 AM:** Bob runs `terraform apply` to create an **RDS MySQL Database**. His computer downloads the exact same state: `[VPC, Subnets]`.
3. **10:02:00 AM:** Alice's ALB finishes creation in AWS. Her machine writes a new state and uploads it to S3:
   * *State in S3:* `[VPC, Subnets, ALB]` ✅
4. **10:05:00 AM (THE DISASTER):** Bob's RDS database finishes creation in AWS. 
   * Bob's computer has **no idea** Alice created an ALB because Bob downloaded the state before Alice's run.
   * Bob's machine appends the RDS database to *his* local state copy and uploads it to S3.
   * **Bob's upload completely OVERWRITES Alice's state file in S3!**
   * *State in S3 is now:* `[VPC, Subnets, RDS]` 💥

### The 3 Severe Consequences:
1. **Orphaned / Ghost Resources:** Alice's ALB is still alive, running, and billing the company in AWS, but Terraform has forgotten it exists! `terraform destroy` will not delete it, and future `terraform apply` runs will fail with name collision errors.
2. **State File Corruption:** If both uploads hit S3 at the exact same millisecond, the JSON file in S3 can become malformed and corrupt, halting all team deployments until an engineer manually edits raw JSON.
3. **Resource Thrashing:** If Alice deletes a subnet while Bob tries to deploy into it simultaneously, half-created broken resources will be scattered across AWS.

### The Solution: DynamoDB State Locking
When a DynamoDB lock table is configured:
1. Alice runs `terraform apply` ➡️ Terraform writes a lock record to DynamoDB: `LockID: project-4, Owner: Alice, Status: LOCKED`.
2. Bob runs `terraform apply` 2 seconds later ➡️ Terraform checks DynamoDB, sees Alice's lock, and **halts immediately** with:
   ```text
   Error: Error acquiring the state lock!
   Lock Info: Owner: Alice, Created: 10:00:00 AM.
   Please wait until the running process completes.
