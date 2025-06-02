# VPC and Subnet Configuration

## VPC
resource "aws_vpc" "vpc_region1" {
    cidr_block           = var.vpc_cidr1
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "Revolut VPC Primary Region"
        project = "Revolut"
        environment = var.env1
        region = var.region1
        owner = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    provider = aws.primary_region
}


resource "aws_vpc" "vpc_region2" {
    cidr_block           = var.vpc_cidr2
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "Revolut VPC Secondary Region"
        project = "Revolut"
        environment = var.env2
        region = var.region2
        owner = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    provider = aws.secondary_region
}

## Subnets

resource "aws_subnet" "private_subnet_region1" {
    count = length(var.subnet_cidrs_db_primary)
    provider          = aws.primary_region
    tags = {
        Name        = "Revolut Private Subnet Primary Region ${count.index + 1}"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    vpc_id            = aws_vpc.vpc_region1.id
    cidr_block        = var.subnet_cidrs_db_primary[count.index]
    availability_zone = var.availability_zones_primary[count.index]
    map_public_ip_on_launch = false

}

resource "aws_subnet" "private_subnet_region2" {
    count = length(var.subnet_cidrs_db_secondary)
    provider          = aws.secondary_region
    tags = {
        Name        = "Revolut Private Subnet Secondary Region ${count.index + 1}"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    vpc_id            = aws_vpc.vpc_region2.id
    cidr_block        = var.subnet_cidrs_db_secondary[count.index]
    availability_zone = var.availability_zones_secondary[count.index]
    map_public_ip_on_launch = false
  
}

## Security Groups for PostgreSQL

resource "aws_security_group" "postgres_sg_region1" {
    name        = "postgres-sg-primary"
    description = "Allow PostgreSQL traffic in the primary region"
    vpc_id      = aws_vpc.vpc_region1.id
    provider    = aws.primary_region

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_app_primary
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "Postgres SG Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}

resource "aws_security_group" "postgres_sg_region2" {
    name        = "postgres-sg-secondary"
    description = "Allow PostgreSQL traffic in the secondary region"
    vpc_id      = aws_vpc.vpc_region2.id
    provider    = aws.secondary_region

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_app_secondary
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "Postgres SG Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}

