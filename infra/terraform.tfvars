assume_role_arn = "arn:aws:iam::154983253182:role/OpentofuRole"
ami_id = "ami-074e262099d145e90"

cost_center=202506
owner = "infra_user"

# Network Configuration

vpc_cidr1 = "10.11.0.0/16"
vpc_cidr2 = "10.12.0.0/16"
subnet_cidrs_db_primary = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
subnet_cidrs_db_secondary = ["10.12.1.0/24", "10.12.2.0/24", "10.12.3.0/24"]
subnet_cidrs_app_primary = ["10.21.1.0/24", "10.21.2.0/24", "10.21.3.0/24"]
subnet_cidrs__app_secondary = ["10.22.1.0/24", "10.22.2.0/24", "10.22.3.0/24"]
availability_zones_primary = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
availability_zones_secondary = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]