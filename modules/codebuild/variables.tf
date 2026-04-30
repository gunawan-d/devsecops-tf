variable "project_name" {
  description = "Name of the project (used for naming CodeBuild resources)"
  type        = string
}

variable "build_timeout" {
  description = "CodeBuild timeout in minutes"
  type        = number
  default     = 60
}

variable "build_compute_type" {
  description = "CodeBuild compute type (e.g., BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "image_repo_name" {
  description = "ECR repository name for Docker images"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to build"
  type        = string
  default     = "latest"
}

variable "buildspec" {
  description = "Path to buildspec.yml file relative to repository root"
  type        = string
  default     = "buildspec.yml"
}

variable "environment_variables" {
  description = "Additional environment variables for CodeBuild: [{name=\"KEY\", value=\"value\"}]"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all CodeBuild resources"
  type        = map(string)
  default     = {}
}
