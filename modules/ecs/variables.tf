variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_task_family" {
  description = "Family name for task definition (used in log group path)"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "ecs_container_name" {
  description = "Container name within the task"
  type        = string
}

variable "ecs_container_image" {
  description = "ECR image URI (e.g., \"[ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/repo:tag\")"
  type        = string
}

variable "ecs_container_port" {
  description = "Container port that the application listens on (1-65535)"
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for task ENIs (from VPC module)"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID (from security_group module)"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN (from ALB module)"
  type        = string
}

variable "ecs_environment_variables" {
  description = "List of environment variables for ECS container: [{name=\"KEY\", value=\"value\"}]"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
