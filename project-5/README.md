# ⚡ Project 5: Serverless Static Site with CloudFront CDN & S3

A globally distributed, ultra-low-latency static website hosted serverlessly on Amazon S3 and accelerated via AWS CloudFront CDN. Direct access to the S3 bucket is strictly blocked using modern **Origin Access Control (OAC)**, forcing all traffic through the secure CloudFront edge network with default HTTPS encryption.

---

## 🏗️ Architecture Diagram

```
[ User Browser ]
       |
       | (HTTPS / TLS)
       v
[ AWS CloudFront CDN ]  <--- (Global Edge Caching & SSL)
       |
       | (Signed SigV4 via OAC)
       v
[ Amazon S3 Bucket ]     <--- (Private: All Direct Public Access Blocked)
  ├── index.html
  └── error.html
```

---

## 🔑 Key Architectural Highlights

- **Serverless & Zero Maintenance:** No EC2 instances, OS patching, or server scaling to manage.
- **Origin Access Control (OAC):** Implements AWS SigV4 cryptographic request signing. S3 bucket policy permits *only* this specific CloudFront distribution ARN, completely mitigating the Confused Deputy problem.
- **Smart Asset Sync with `etag`:** Uses Terraform `filemd5()` hashing to dynamically detect changes in local HTML assets and update S3 objects during `apply`.
- **Custom Error Handling:** Automatically intercepts HTTP 403 / 404 responses and serves a custom styled `error.html` page with low TTL error caching.
- **Cost-Optimized Caching:** Leverages AWS's official `Managed-CachingOptimized` cache policy for high cache hit ratios.

---

## 📁 File Structure

```
project-5/
├── provider.tf      # S3 Remote State backend & AWS Provider
├── variables.tf     # Configurable project variables
├── s3.tf            # S3 bucket, block public access, bucket policy, & object uploads
├── cloudfront.tf    # CloudFront distribution, OAC, cache behavior, & error routing
├── outputs.tf       # CloudFront URL, direct S3 URL, & bucket name
└── website/
    ├── index.html   # Modern responsive landing page
    └── error.html   # Custom 404 error page
```

---

## 🚀 How to Run

```bash
# 1. Initialize remote state
terraform init

# 2. Review execution plan
terraform plan

# 3. Deploy infrastructure & upload assets
terraform apply -auto-approve
```

---

## 🧪 Verification

1. **CDN Delivery:** Open `website_url` output (`https://<distribution-id>.cloudfront.net`). Confirms instant global delivery and valid HTTPS.
2. **Access Security:** Open `s3_bucket_direct_url`. Confirms direct access returns `403 Access Denied`.
3. **Error Routing:** Navigate to a nonexistent route (e.g. `/not-found`). Confirms redirection to `error.html`.

---

## 🧹 Teardown

```bash
terraform destroy -auto-approve
```
