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

## Internet Gateway for Primary Region
resource "aws_internet_gateway" "igw_primary" {
    vpc_id  = aws_vpc.vpc_region1.id
    provider = aws.primary_region

    tags = {
        Name        = "Internet Gateway Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## Internet Gateway for Secondary Region
resource "aws_internet_gateway" "igw_secondary" {
    vpc_id  = aws_vpc.vpc_region2.id
    provider = aws.secondary_region

    tags = {
        Name        = "Internet Gateway Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        cost_center = var.cost_center
    }
}

# Subnets for Database Instances

resource "aws_subnet" "private_subnet_region1" {
    count = length(var.subnet_cidrs_db_primary)
    provider          = aws.primary_region
    tags = {
        Name        = "private-dbs-${count.index + 1}"
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
    map_public_ip_on_launch = true

}

resource "aws_subnet" "private_subnet_region2" {
    count = length(var.subnet_cidrs_db_secondary)
    provider          = aws.secondary_region
    tags = {
        Name        = "private-dbs-${count.index + 1}"
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
    map_public_ip_on_launch = true
  
}

## Subnets for Application Instances
resource "aws_subnet" "public_subnet_region1" {
    count = length(var.subnet_cidrs_app_primary)
    provider          = aws.primary_region
    tags = {
        Name        = "public-apps-${count.index + 1}"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    vpc_id            = aws_vpc.vpc_region1.id
    cidr_block        = var.subnet_cidrs_app_primary[count.index]
    availability_zone = var.availability_zones_primary[count.index]
    map_public_ip_on_launch = true

}

resource "aws_subnet" "public_subnet_region2" {
    count = length(var.subnet_cidrs_app_secondary)
    provider          = aws.secondary_region
    tags = {
        Name        = "public-app-${count.index + 1}"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    vpc_id            = aws_vpc.vpc_region2.id
    cidr_block        = var.subnet_cidrs_app_secondary[count.index]
    availability_zone = var.availability_zones_secondary[count.index]
    map_public_ip_on_launch = true
  
}

## Elastic IP for NAT Gateway in Primary Region
resource "aws_eip" "nat_eip_primary" {
    provider = aws.primary_region

    tags = {
        Name        = "NAT EIP Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## NAT Gateway in Primary Region
resource "aws_nat_gateway" "nat_gateway_primary" {
    allocation_id = aws_eip.nat_eip_primary.id
    subnet_id     = aws_subnet.public_subnet_region1[0].id 
    provider      = aws.primary_region

    tags = {
        Name        = "NAT Gateway Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## Elastic IP for NAT Gateway in Secondary Region
resource "aws_eip" "nat_eip_secondary" {
    provider = aws.secondary_region

    tags = {
        Name        = "NAT EIP Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## NAT Gateway in Secondary Region
resource "aws_nat_gateway" "nat_gateway_secondary" {
    allocation_id = aws_eip.nat_eip_secondary.id
    subnet_id     = aws_subnet.public_subnet_region2[0].id // Use the first public subnet
    provider      = aws.secondary_region

    tags = {
        Name        = "NAT Gateway Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        cost_center = var.cost_center
    }
}

resource "aws_route_table" "public_route_table_primary" {
    vpc_id = aws_vpc.vpc_region1.id
    provider = aws.primary_region

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_primary.id
    }

    tags = {
        Name        = "Public Route Table Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        cost_center = var.cost_center
    }
}

resource "aws_route_table_association" "public_route_assoc_primary" {
    count          = length(var.subnet_cidrs_app_primary)
    subnet_id      = aws_subnet.public_subnet_region1[count.index].id
    route_table_id = aws_route_table.public_route_table_primary.id
    provider       = aws.primary_region
}

resource "aws_route_table" "public_route_table_secondary" {
    vpc_id = aws_vpc.vpc_region2.id
    provider = aws.secondary_region

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_secondary.id
    }

    tags = {
        Name        = "Public Route Table Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        cost_center = var.cost_center
    }
}

resource "aws_route_table_association" "public_route_assoc_secondary" {
    count          = length(var.subnet_cidrs_app_secondary)
    subnet_id      = aws_subnet.public_subnet_region2[count.index].id
    route_table_id = aws_route_table.public_route_table_secondary.id
    provider       = aws.secondary_region
}


## Route Table for Private Subnets in Primary Region
resource "aws_route_table" "private_route_table_primary" {
    vpc_id = aws_vpc.vpc_region1.id
    provider = aws.primary_region

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway_primary.id
    }

    tags = {
        Name        = "Private Route Table Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## Route Table Association for Private Subnets in Primary Region
resource "aws_route_table_association" "private_route_assoc_primary" {
    count          = length(var.subnet_cidrs_db_primary)
    subnet_id      = aws_subnet.private_subnet_region1[count.index].id
    route_table_id = aws_route_table.private_route_table_primary.id
    provider       = aws.primary_region
}

## Route Table for Private Subnets in Secondary Region
resource "aws_route_table" "private_route_table_secondary" {
    vpc_id = aws_vpc.vpc_region2.id
    provider = aws.secondary_region

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway_secondary.id
    }

    tags = {
        Name        = "Private Route Table Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        cost_center = var.cost_center
    }
}

## Route Table Association for Private Subnets in Secondary Region
resource "aws_route_table_association" "private_route_assoc_secondary" {
    count          = length(var.subnet_cidrs_db_secondary)
    subnet_id      = aws_subnet.private_subnet_region2[count.index].id
    route_table_id = aws_route_table.private_route_table_secondary.id
    provider       = aws.secondary_region
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

