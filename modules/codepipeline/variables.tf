variable "project_name" {
  description = "Name of the project (used for naming CodePipeline resources)"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub personal access token (PAT) with repo access. Set via environment variable for security."
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "GitHub repository in format \"owner/repository\""
  type        = string
  default     = "gunawan-d/apps-tf"
}

variable "github_branch" {
  description = "GitHub branch to trigger pipeline from"
  type        = string
  default     = "main"
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project to integrate with pipeline"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to deploy to"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to update"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all CodePipeline resources"
  type        = map(string)
  default     = {}
}
