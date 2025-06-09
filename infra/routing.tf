
## Route Table for Public Subnets in Primary Region
resource "aws_route_table" "public_route_table_primary" {
    vpc_id = aws_vpc.vpc_region1.id
    provider = aws.primary_region

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

## Route Table for Public Subnets in Secondary Region
resource "aws_route_table" "public_route_table_secondary" {
    vpc_id = aws_vpc.vpc_region2.id
    provider = aws.secondary_region

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

## Internet Gateway for Primary Region
resource "aws_route" "public_internet_route_primary" {
    route_table_id         = aws_route_table.public_route_table_primary.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw_primary.id
    provider               = aws.primary_region
  
}

## Internet Gateway for Secondary Region
resource "aws_route" "public_internet_route_secondary" {
    route_table_id         = aws_route_table.public_route_table_secondary.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw_secondary.id
    provider               = aws.secondary_region
  
}

## NAT Gateway Route for Primary Region
resource "aws_route" "private_nat_route_primary" {
  route_table_id         = aws_route_table.private_route_table_primary.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_primary.id
  provider               = aws.primary_region
}

## NAT Gateway Route for Secondary Region
resource "aws_route" "private_nat_route_secondary" {
  route_table_id         = aws_route_table.private_route_table_secondary.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_secondary.id
  provider               = aws.secondary_region
}

## Add Peering Route to Public Route Table in Primary Region
resource "aws_route" "peering_route_primary" {
  route_table_id         = aws_route_table.public_route_table_primary.id
  destination_cidr_block = var.vpc_cidr2
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  provider               = aws.primary_region
}

## Add Peering Route to Public Route Table in Secondary Region
resource "aws_route" "peering_route_secondary" {
  route_table_id         = aws_route_table.public_route_table_secondary.id
  destination_cidr_block = var.vpc_cidr1
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  provider               = aws.secondary_region
}

## Add Peering Route to Private Route Table in Primary Region
resource "aws_route" "peering_route_primary1" {
  route_table_id         = aws_route_table.private_route_table_primary.id
  destination_cidr_block = var.vpc_cidr2
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  provider               = aws.primary_region
}

## Add Peering Route to Private Route Table in Secondary Region
resource "aws_route" "peering_route_secondary2" {
  route_table_id         = aws_route_table.private_route_table_secondary.id
  destination_cidr_block = var.vpc_cidr1
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  provider               = aws.secondary_region
}