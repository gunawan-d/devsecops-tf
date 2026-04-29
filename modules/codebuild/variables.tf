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

variable "aws_region" {
  description = "AWS region"
  type        = string
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

variable "environment_variables" {
  description = "Additional environment variables for CodeBuild"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
