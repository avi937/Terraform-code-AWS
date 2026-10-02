output "website_url" {
  description = "The public HTTPS CloudFront URL to access your global website"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "s3_bucket_direct_url" {
  description = "Direct S3 URL (Opening this proves that public direct access is blocked with 403 Access Denied)"
  value       = "https://${aws_s3_bucket.site_bucket.bucket_regional_domain_name}/index.html"
}

output "s3_bucket_name" {
  description = "The globally unique name of the S3 bucket"
  value       = aws_s3_bucket.site_bucket.id
}
