# Updated network SSM Session Manager support

## Add Security Group rules for SSM and HTTPS egress (needed by SSM agent)

resource "aws_security_group" "ssm_sg_region1" {
  name        = "ssm-sg-primary"
  description = "Allow SSM Agent connectivity in primary region"
  vpc_id      = aws_vpc.vpc_region1.id
  provider    = aws.primary_region

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = var.subnet_cidrs_db_primary
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SSM SG Primary"
    project     = "Revolut"
    environment = var.env1
    region      = var.region1
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "aws_security_group" "ssm_sg_region2" {
  name        = "ssm-sg-secondary"
  description = "Allow SSM Agent connectivity in secondary region"
  vpc_id      = aws_vpc.vpc_region2.id
  provider    = aws.secondary_region

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = var.subnet_cidrs_db_primary
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SSM SG Secondary"
    project     = "Revolut"
    environment = var.env2
    region      = var.region2
    owner       = var.owner
    cost_center = var.cost_center
  }
}

# Add SSM security groups to EC2 instances (in your compute module or main.tf):
# Example:
# vpc_security_group_ids = [aws_security_group.postgres_sg_region1.id, aws_security_group.ssm_sg_region1.id]

# Optional: if no NAT Gateway, define VPC endpoints for SSM (if in private subnet)
resource "aws_vpc_endpoint" "ssm_region1" {
  vpc_id            = aws_vpc.vpc_region1.id
  service_name      = "com.amazonaws.${var.region1}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region1 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region1.id]
  provider          = aws.primary_region
}

resource "aws_vpc_endpoint" "ssmmessages_region1" {
  vpc_id            = aws_vpc.vpc_region1.id
  service_name      = "com.amazonaws.${var.region1}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region1 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region1.id]
  provider          = aws.primary_region
}

resource "aws_vpc_endpoint" "ec2messages_region1" {
  vpc_id            = aws_vpc.vpc_region1.id
  service_name      = "com.amazonaws.${var.region1}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region1 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region1.id]
  provider          = aws.primary_region
}

# Repeat for Region 2 as needed
resource "aws_vpc_endpoint" "ssm_region2" {
  vpc_id            = aws_vpc.vpc_region2.id
  service_name      = "com.amazonaws.${var.region2}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region2 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region2.id]
  provider          = aws.secondary_region
}

resource "aws_vpc_endpoint" "ssmmessages_region2" {
  vpc_id            = aws_vpc.vpc_region2.id
  service_name      = "com.amazonaws.${var.region2}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region2 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region2.id]
  provider          = aws.secondary_region
}

resource "aws_vpc_endpoint" "ec2messages_region2" {
  vpc_id            = aws_vpc.vpc_region2.id
  service_name      = "com.amazonaws.${var.region2}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.private_subnet_region2 : subnet.id]
  security_group_ids = [aws_security_group.ssm_sg_region2.id]
  provider          = aws.secondary_region
}