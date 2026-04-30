variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

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

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
