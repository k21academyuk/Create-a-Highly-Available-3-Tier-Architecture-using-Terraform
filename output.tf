output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "The public subnets of the VPC"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "The private subnets of the VPC"
}

output "rds_instance_endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "The endpoint of the RDS instance"
}

output "load_balancer_dns_name" {
  value       = aws_lb.K21LB.dns_name
  description = "The DNS name of the Network Load Balancer"
}
