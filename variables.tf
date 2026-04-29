### VPC Variables ###
variable "vpc_cidr" {}
variable "public_subnet" {}
variable "public_subnet_b" {}
variable "private_subnet" {}
variable "private_subnet_b" {}
variable "az" {}
variable "az_2" {}
variable "key_name" {}
variable "public_key" {}

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
