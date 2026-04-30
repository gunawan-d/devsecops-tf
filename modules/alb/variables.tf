variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB (minimum 2 for high availability)"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "alb_name" {
  description = "Name tag for the Application Load Balancer"
  type        = string
  default     = "app-alb"
}

variable "target_group_name" {
  description = "Name for the target group"
  type        = string
  default     = "app-tg"
}

variable "target_group_port" {
  description = "Port number for target group routing (1-65535)"
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
  description = "Endpoint path for health checks"
  type        = string
  default     = "/health"
}

variable "health_check_matcher" {
  description = "HTTP status codes considered healthy (e.g., \"200-399\")"
  type        = string
  default     = "200-399"
}

variable "ssl_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (optional - enables HTTPS if provided)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
