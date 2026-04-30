output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.lab_1.id
}

output "public_subnet_id" {
  description = "ID of the first public subnet (AZ-a)"
  value       = aws_subnet.public.id
}

output "public_subnet_id_2" {
  description = "ID of the second public subnet (AZ-b)"
  value       = aws_subnet.public_b.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public.id, aws_subnet.public_b.id]
}

output "private_subnet_id" {
  description = "ID of the first private subnet (AZ-a)"
  value       = aws_subnet.private.id
}

output "private_subnet_id_2" {
  description = "ID of the second private subnet (AZ-b)"
  value       = aws_subnet.private_b.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private.id, aws_subnet.private_b.id]
}
