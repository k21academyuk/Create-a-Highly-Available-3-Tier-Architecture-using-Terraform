provider "aws" {
  region     = "us-west-2"
  access_key = "****"
  secret_key = "****"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "K21vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-west-2a", "us-west-2b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = false
  single_nat_gateway = true
  public_subnet_tags = {
    Name = "Public-Subnets"
  }
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
  vpc_tags = {
    Name = "K21VPC"
  }
}

data "aws_rds_engine_version" "latest_mysql" {
  engine = "mysql"
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "RDS security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds_sg"
    Environment = "dev"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "my-db-subnet-group"
  subnet_ids = [
    module.vpc.private_subnets[0], # Subnet in us-west-2a
    module.vpc.private_subnets[1]  # Subnet in us-west-2b
  ]
  tags = {
    Name        = "my-db-subnet-group"
    Environment = "dev"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = data.aws_rds_engine_version.latest_mysql.version
  instance_class       = "db.t3.micro"
  db_name              = "K21_initial_db"
  username             = "K21Academy"
  password             = "Deep12345"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  # Add these lines to handle final snapshot on deletion
  skip_final_snapshot       = false
  final_snapshot_identifier = "final-snapshot-${var.environment}"

  tags = {
    Name        = "K21DBInstance"
    Environment = "dev"
  }
}

resource "aws_lb" "K21LB" {
  name                       = "K21LB"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  tags = {
    Name        = "K21LB"
    Environment = "dev"
  }
}
