### VPC Variables ###
variable "vpc_cidr" {}
variable "public_subnet" {}
variable "public_subnet_b" {}
variable "private_subnet" {}
variable "private_subnet_b" {}
variable "az" {}
variable "az_2" {}

### SG and ALB Variables ###
variable "app_port" {}
variable "alb_sg_name" {}
variable "ecs_sg_name" {}
variable "alb_name" {}
variable "target_group_name" {}
variable "target_group_port" {}
variable "target_group_protocol" {}
variable "health_check_path" {}
variable "health_check_matcher" {}

#### ECS Variables ####
variable "ecs_cluster_name" {}
variable "ecs_task_family" {}
variable "ecs_service_name" {}
variable "ecs_container_name" {}
variable "ecs_container_image" {}
variable "ecs_task_cpu" {}
variable "ecs_task_memory" {}
variable "ecs_desired_count" {}
variable "ecs_container_port" {}
variable "aws_region" {}
variable "ecs_environment_variables" {
  description = "Environment variables for the ECS container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "ssl_certificate_arn" {
  description = "ACM SSL certificate ARN"
  type        = string
  default     = null  # Optional - can be null for HTTP-only
}

### CodeBuild and CodePipeline Variables ###
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60
}

variable "build_compute_type" {
  description = "Build compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "Build image"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "image_repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "buildspec" {
  description = "Buildspec file path or content"
  type        = string
  default     = "buildspec.yml"
}

variable "codebuild_environment_variables" {
  description = "Environment variables for CodeBuild"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "github_oauth_token" {
  description = "GitHub OAuth token"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "GitHub repository (owner/repository)"
  type        = string
  default     = "gunawan-d/apps-tf"
}

variable "github_branch" {
  description = "GitHub branch to build from"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
