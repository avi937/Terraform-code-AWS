# 1. Random suffix for globally unique S3 bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. S3 Bucket for Static Website Assets
resource "aws_s3_bucket" "site_bucket" {
  bucket        = "${var.project_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allows terraform destroy to cleanly wipe the bucket even if it has files

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = "Dev"
  }
}

# 3. Block All Public Direct Access to S3 (Crucial Security Best Practice!)
resource "aws_s3_bucket_public_access_block" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Upload index.html to S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site_bucket.id
  key          = "index.html"
  source       = "${path.module}/website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/index.html")
}

# 5. Upload error.html to S3
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.site_bucket.id
  key          = "error.html"
  source       = "${path.module}/website/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/error.html")
}

# 6. S3 Bucket Policy: Only allow CloudFront via Origin Access Control (OAC)
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

/*
1. What is random_id.bucket_suffix.hex?
    -> In random_id, byte_length = 4 generates 4 raw bytes of randomness.
       .hex converts those 4 bytes into a readable hexadecimal string (0-9, a-f).
        Since 1 byte = 2 hex characters, 4 bytes = 8 characters (e.g., 4a7b9c1d).
        So ${var.project_name}-${random_id.bucket_suffix.hex} becomes something like:
        static-site-cdn-4a7b9c1d
        It's URL-friendly, lowercase, and guarantees no one else in the world shares your bucket name.

2. What is etag = filemd5(...)?
   -> This is a classic Terraform trick that every DevOps engineer uses for S3!
   -> Without etag: If you upload index.html today, and tomorrow you edit the HTML text to say "Hello World 2.0", Terraform will not notice the change because the file name is still index.html. It will say "No changes. Your infrastructure matches."
   -> With etag = filemd5(...): filemd5() calculates a unique cryptographic fingerprint (hash) of the file's text.
   -> If you change even one single letter in index.html, the MD5 hash changes.
   -> Terraform detects the hash difference and says: "Aha! The contents of index.html changed! I will automatically re-upload the new file to S3."*/
