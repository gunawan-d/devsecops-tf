output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_sg_id" {
  description = "ALB security group ID"
  value       = module.sg.alb_sg_id
}

output "ecs_sg_id" {
  description = "ECS security group ID"
  value       = module.sg.ecs_sg_id
}

output "alb_dns_name" {
  description = "ALB DNS name (use for Cloudflare CNAME)"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "Target group ARN (used by ECS service)"
  value       = module.alb.target_group_arn
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "ecs_service_id" {
  description = "ECS service ID"
  value       = module.ecs.service_id
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = module.ecs.task_definition_arn
}

output "codebuild_project_id" {
  description = "CodeBuild project ID"
  value       = module.codebuild.codebuild_project_id
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = module.codebuild.codebuild_project_name
}

output "codepipeline_id" {
  description = "CodePipeline ID"
  value       = module.codepipeline.codepipeline_id
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = module.codepipeline.codepipeline_name
}

output "codepipeline_s3_bucket" {
  description = "CodePipeline S3 bucket name for artifacts"
  value       = module.codepipeline.s3_bucket_name
}
