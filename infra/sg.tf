## Security Groups for PostgreSQL

resource "aws_security_group" "app_sg_region1"{
    name        = "app-sg-primary"
    description = "Allow application traffic in the primary region"
    vpc_id      = aws_vpc.vpc_region1.id
    provider    = aws.primary_region


    ingress {
        from_port   = 5000
        to_port     = 5000
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
        Name        = "App SG Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}



resource "aws_security_group" "postgres_sg_region1" {
    name        = "postgres-sg-primary"
    description = "Allow PostgreSQL traffic in the primary region"
    vpc_id      = aws_vpc.vpc_region1.id
    provider    = aws.primary_region

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_app_primary
    }
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_app_secondary
    }
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
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
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }
        ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_app_primary
    }
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

## Security Group to Allow SSH Access

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH access from anywhere"
    vpc_id      = aws_vpc.vpc_region1.id

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.8.0.0/13"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.8.0.0/13"]
    }

    tags = {
        Name = "allow_ssh"
    }
    provider = aws.primary_region
}
resource "aws_security_group" "allow_ssh2" {
    name        = "allow_ssh"
    description = "Allow SSH access from anywhere"
    vpc_id      = aws_vpc.vpc_region2.id

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.8.0.0/13"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.8.0.0/13"]
    }

    tags = {
        Name = "allow_ssh"
    }
    provider = aws.secondary_region
}

## Security Groups for etcd

resource "aws_security_group" "etcd_sg_region1" {
    name        = "etcd-sg-primary"
    description = "Allow etcd traffic in the primary region"
    vpc_id      = aws_vpc.vpc_region1.id
    provider    = aws.primary_region
    ingress {
        from_port   = 2379
        to_port     = 2379
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    ingress {
        from_port   = 2380
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
     ingress {
        from_port   = 2379
        to_port     = 2379
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }
    ingress {
        from_port   = 2380
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }
    ingress {
        from_port   = 2379
        to_port     = 2379
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.11.0.0/16","10.12.0.0/16"]
    }
    tags = {
        Name = "ectd SG Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    
}

resource "aws_security_group" "etcd_sg_region2" {
    name        = "etcd-sg-secondary"
    description = "Allow etcd traffic in the secondary region"
    vpc_id      = aws_vpc.vpc_region2.id
    provider    = aws.secondary_region
    ingress {
        from_port   = 2379
        to_port     = 2379
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }
    ingress {
        from_port   = 2380
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }
        ingress {
        from_port   = 2379
        to_port     = 2379
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    ingress {
        from_port   = 2380
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.11.0.0/16","10.12.0.0/16"]
    }
    tags = {
        Name = "ectd SG Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}

# Ports for patroni

resource "aws_security_group" "patroni_sg_region1" {
    name        = "patroni-sg-primary"
    description = "Allow patroni traffic in the primary region"
    vpc_id      = aws_vpc.vpc_region1.id
    provider    = aws.primary_region
    ingress {
        from_port   = 8008
        to_port     = 8008
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    ingress {
        from_port   = 8008
        to_port     = 8008
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.11.0.0/16","10.12.0.0/16"]
    }
    tags = {
        Name = "patroni SG Primary Region"
        project     = "Revolut"
        environment = var.env1
        region      = var.region1
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
    
}
resource "aws_security_group" "patroni_sg_region2" {
    name        = "patroni-sg-secondary"
    description = "Allow patroni traffic in the secondary region"
    vpc_id      = aws_vpc.vpc_region2.id
    provider    = aws.secondary_region
    ingress {
        from_port   = 8008
        to_port     = 8008
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_primary
    }
    ingress {
        from_port   = 8008
        to_port     = 8008
        protocol    = "tcp"
        cidr_blocks = var.subnet_cidrs_db_secondary
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.11.0.0/16","10.12.0.0/16"]
    }
    tags = {
        Name = "patroni SG Secondary Region"
        project     = "Revolut"
        environment = var.env2
        region      = var.region2
        owner       = var.owner
        application = "revolut"
        cost_center = var.cost_center
    }
}