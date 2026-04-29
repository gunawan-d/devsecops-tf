output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "alb_security_group_id" {
  value = module.sg.alb_sg_id
}

output "ecs_security_group_id" {
  value = module.sg.ecs_sg_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_cluster_id" {
  value = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_id" {
  value = module.ecs.service_id
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}