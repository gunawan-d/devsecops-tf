provider "aws" {
  region = "ap-southeast-3"
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  public_subnet    = var.public_subnet
  public_subnet_b  = var.public_subnet_b
  private_subnet   = var.private_subnet
  private_subnet_b = var.private_subnet_b
  az               = var.az
  az_2             = var.az_2
}

module "sg" {
  source   = "./modules/security_group"
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
  alb_sg_name = var.alb_sg_name
  ecs_sg_name = var.ecs_sg_name
}

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  security_group_id     = module.sg.alb_sg_id
  alb_name              = var.alb_name
  target_group_name     = var.target_group_name
  target_group_port     = var.target_group_port
  target_group_protocol = var.target_group_protocol
  health_check_path     = var.health_check_path
  health_check_matcher  = var.health_check_matcher
  ssl_certificate_arn   = var.ssl_certificate_arn
}

module "ecs" {
  source                = "./modules/ecs"
  ecs_cluster_name      = var.ecs_cluster_name
  ecs_task_family       = var.ecs_task_family
  ecs_service_name      = var.ecs_service_name
  ecs_container_name    = var.ecs_container_name
  ecs_container_image   = var.ecs_container_image
  ecs_container_port    = var.ecs_container_port
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  ecs_desired_count     = var.ecs_desired_count
  aws_region            = var.aws_region
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.sg.ecs_sg_id
  target_group_arn      = module.alb.target_group_arn
  ecs_environment_variables = var.ecs_environment_variables
}
