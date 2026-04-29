output "codepipeline_id" {
  description = "CodePipeline ID"
  value       = aws_codepipeline.codepipeline.id
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.codepipeline.arn
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.codepipeline.name
}

output "s3_bucket_name" {
  description = "S3 bucket name for artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}
