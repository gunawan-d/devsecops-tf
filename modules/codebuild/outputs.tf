output "codebuild_project_id" {
  description = "CodeBuild project ID"
  value       = aws_codebuild_project.codebuild.id
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.codebuild.arn
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.codebuild.name
}
