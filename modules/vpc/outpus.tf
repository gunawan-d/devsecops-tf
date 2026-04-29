output "vpc_id" {
  value = aws_vpc.lab_1.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_subnet_id_2" {
  value = aws_subnet.public_b.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public.id, aws_subnet.public_b.id]
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "private_subnet_id_2" {
  value = aws_subnet.private_b.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private.id, aws_subnet.private_b.id]
}