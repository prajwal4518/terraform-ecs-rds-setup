output "vpc_id" {
  description = "The default VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "The default subnet ID"
  value       = aws_subnet.public1[*].id
}

output "private_subnet_ids" {
  description = "The default subnet ID"
  value       = aws_subnet.private1[*].id
}


