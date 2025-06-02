# VPC and Subnet Configuration

## VPC
resource "aws_vpc" "vpc_region1" {
    cidr_block           = var.vpc_cidr1
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "Revolut VPC Primary Region"
        project = "Revolut"
        environment = "primary"
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
        environment = "secondary"
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
        environment = "primary"
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
        environment = "secondary"
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