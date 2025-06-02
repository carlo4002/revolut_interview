## Network ACLs for Primary Region
resource "aws_network_acl" "nacl_primary" {
    vpc_id = aws_vpc.vpc_region1.id
    provider = aws.primary_region
    tags = {
        Name        = "Primary Region NACL"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}

## Network ACLs for Secondary Region
resource "aws_network_acl" "nacl_secondary" {
    vpc_id = aws_vpc.vpc_region2.id
    provider = aws.secondary_region
    tags = {
        Name        = "Secondary Region NACL"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}

#Rule for PostgreSQL access in Primary Region
resource "aws_network_acl_rule" "allow_postgres_access1" {
    count           = length(var.subnet_cidrs_app_primary)
    network_acl_id  = aws_network_acl.nacl_primary.id
    rule_number     = 100 + count.index
    protocol        = "tcp"
    rule_action     = "allow"
    egress          = false
    cidr_block      = var.subnet_cidrs_app_primary[count.index]
    from_port       = 5432
    to_port         = 5432
    provider        = aws.primary_region
}

resource "aws_network_acl_rule" "allow_all_egress1" {
    network_acl_id = aws_network_acl.nacl_primary.id
    rule_number    = 300
    protocol       = "-1"
    rule_action    = "allow"
    egress         = true
    cidr_block     = "0.0.0.0/0"
    provider        = aws.primary_region
}

#Rule for PostgreSQL access in Secondary Region
resource "aws_network_acl_rule" "allow_postgres_access2" {
    count           = length(var.subnet_cidrs_app_secondary)
    network_acl_id  = aws_network_acl.nacl_secondary.id
    rule_number     = 200 + count.index
    protocol        = "tcp"
    rule_action     = "allow"
    egress          = false
    cidr_block      = var.subnet_cidrs_app_secondary[count.index]
    from_port       = 5432
    to_port         = 5432
    provider        = aws.secondary_region
}

resource "aws_network_acl_rule" "allow_all_egress2" {
    network_acl_id = aws_network_acl.nacl_secondary.id
    rule_number    = 300
    protocol       = "-1"
    rule_action    = "allow"
    egress         = true
    cidr_block     = "0.0.0.0/0"
    provider       = aws.secondary_region
}

## Network ACL Associations for Primary Region
resource "aws_network_acl_association" "nacl_assoc_primary" {
    count          = length(var.subnet_cidrs_db_primary)
    subnet_id      = aws_subnet.private_subnet_region1[count.index].id
    network_acl_id = aws_network_acl.nacl_primary.id
    provider       = aws.primary_region
}

resource "aws_network_acl_association" "nacl_assoc_app_primary" {
    count          = length(var.subnet_cidrs_app_primary)
    subnet_id      = aws_subnet.private_subnet_region1[count.index].id
    network_acl_id = aws_network_acl.nacl_primary.id
    provider       = aws.primary_region
}

## Network ACL Associations for Secondary Region
resource "aws_network_acl_association" "nacl_assoc_secondary" {
    count          = length(var.subnet_cidrs_db_secondary)
    subnet_id      = aws_subnet.private_subnet_region2[count.index].id
    network_acl_id = aws_network_acl.nacl_secondary.id
    provider       = aws.secondary_region
}

resource "aws_network_acl_association" "nacl_assoc_app_secondary" {
    count          = length(var.subnet_cidrs_app_secondary)
    subnet_id      = aws_subnet.private_subnet_region2[count.index].id
    network_acl_id = aws_network_acl.nacl_secondary.id
    provider       = aws.secondary_region
}


