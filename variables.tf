#############################
# VPC Network Configuration #
#############################

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., \"10.0.0.0/16\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet" {
  description = "CIDR block for the first public subnet in AZ-a (e.g., \"10.0.0.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.public_subnet))
    error_message = "public_subnet must be a valid CIDR block."
  }
}

variable "public_subnet_b" {
  description = "CIDR block for the second public subnet in AZ-b (e.g., \"10.0.4.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.public_subnet_b))
    error_message = "public_subnet_b must be a valid CIDR block."
  }
}

variable "private_subnet" {
  description = "CIDR block for the first private subnet in AZ-a (e.g., \"10.0.8.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.private_subnet))
    error_message = "private_subnet must be a valid CIDR block."
  }
}

variable "private_subnet_b" {
  description = "CIDR block for the second private subnet in AZ-b (e.g., \"10.0.12.0/22\")"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.private_subnet_b))
    error_message = "private_subnet_b must be a valid CIDR block."
  }
}

#############################
# Security Group & ALB      #
#############################

variable "app_port" {
  description = "Application container port on ECS tasks (1-65535)"
  type        = number
  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "alb_sg_name" {
  description = "Name tag for ALB security group"
  type        = string
  default     = "alb-sg"
}

variable "ecs_sg_name" {
  description = "Name tag for ECS security group"
  type        = string
  default     = "ecs-sg"
}

variable "alb_name" {
  description = "Name tag for the Application Load Balancer"
  type        = string
  default     = "app-alb"
}

variable "target_group_name" {
  description = "Name for the ALB target group"
  type        = string
  default     = "app-tg"
}

variable "target_group_port" {
  description = "Port number for target group routing (should match container port)"
  type        = number
  default     = 8080
  validation {
    condition     = var.target_group_port >= 1 && var.target_group_port <= 65535
    error_message = "target_group_port must be between 1 and 65535."
  }
}

variable "target_group_protocol" {
  description = "Protocol for target group (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_group_protocol)
    error_message = "target_group_protocol must be either HTTP or HTTPS."
  }
}

variable "health_check_path" {
  description = "Endpoint path for ALB health checks"
  type        = string
  default     = "/health"
}

variable "health_check_matcher" {
  description = "HTTP status codes considered healthy (e.g., \"200-399\")"
  type        = string
  default     = "200-399"
}

variable "ssl_certificate_arn" {
  description = "ACM SSL certificate ARN for HTTPS (optional - set to null for HTTP only)"
  type        = string
  default     = null
}

#############################
# ECS Configuration         #
#############################

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_task_family" {
  description = "Family name for ECS task definition (used in log group path)"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "ecs_container_name" {
  description = "Container name within the ECS task"
  type        = string
}

variable "ecs_container_image" {
  description = "ECR image URI (e.g., \"[ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/repo:tag\")"
  type        = string
}

variable "ecs_container_port" {
  description = "Container port that the application listens on"
  type        = number
  validation {
    condition     = var.ecs_container_port >= 1 && var.ecs_container_port <= 65535
    error_message = "ecs_container_port must be between 1 and 65535."
  }
}

variable "ecs_task_cpu" {
  description = "CPU units for Fargate task (valid: 256, 512, 1024, 2048)"
  type        = string
  validation {
    condition     = contains(["256", "512", "1024", "2048"], var.ecs_task_cpu)
    error_message = "ecs_task_cpu must be one of: 256, 512, 1024, 2048."
  }
}

variable "ecs_task_memory" {
  description = "Memory in MiB for Fargate task (valid: 512, 1024, 2048, 4096, 8192, 16384)"
  type        = string
  validation {
    condition     = contains(["512", "1024", "2048", "4096", "8192", "16384"], var.ecs_task_memory)
    error_message = "ecs_task_memory must be one of: 512, 1024, 2048, 4096, 8192, 16384."
  }
}

variable "ecs_desired_count" {
  description = "Number of ECS tasks to run simultaneously (0 for no tasks)"
  type        = number
  default     = 2
  validation {
    condition     = var.ecs_desired_count >= 0
    error_message = "ecs_desired_count must be 0 or greater."
  }
}

variable "ecs_environment_variables" {
  description = "List of environment variables for ECS container: [{name=\"KEY\", value=\"value\"}]"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "aws_region" {
  description = "AWS region to deploy resources (alternatively use data source)"
  type        = string
  default     = "us-east-1"
}

#############################
# CodeBuild & CodePipeline  #
#############################

variable "project_name" {
  description = "Name of the project (used for CodeBuild and CodePipeline resources)"
  type        = string
}

variable "build_timeout" {
  description = "CodeBuild timeout in minutes"
  type        = number
  default     = 60
}

variable "build_compute_type" {
  description = "CodeBuild compute type (BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, etc.)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "aws_account_id" {
  description = "AWS Account ID (auto-detected from AWS credentials if not provided)"
  type        = string
  default     = ""
}

variable "image_repo_name" {
  description = "ECR repository name for Docker images"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to build and deploy"
  type        = string
  default     = "latest"
}

variable "buildspec" {
  description = "Path to buildspec.yml file (relative to repository root)"
  type        = string
  default     = "buildspec.yml"
}

variable "codebuild_environment_variables" {
  description = "Additional environment variables for CodeBuild: [{name=\"KEY\", value=\"value\"}]"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "github_oauth_token" {
  description = "GitHub personal access token (PAT) with repo access. WARNING: Never hardcode - use environment variable: export TF_VAR_github_oauth_token=\"your_token\""
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "GitHub repository in format \"owner/repository\""
  type        = string
  default     = "gunawan-d/apps-tf"
}

variable "github_branch" {
  description = "GitHub branch to trigger builds from"
  type        = string
  default     = "main"
}

#############################
# Global Tags & Metadata    #
#############################

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "development"
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "terraform"
    Environment = "development"
  }
}
