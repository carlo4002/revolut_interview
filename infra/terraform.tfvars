assume_role_arn = "arn:aws:iam::154983253182:role/OpentofuRole"
ami_id_primary = "ami-074e262099d145e90"
ami_id_secondary = "ami-03d8b47244d950bbb"
cost_center=202506
owner = "infra_user"
#environment 
env1 = "primary_production"
env2 = "secondary_production"

# Regions
region1 = "eu-west-3" # Primary region
region2 = "eu-west-1" # Secondary region

availability_zones_primary = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
availability_zones_secondary = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# Network Configuration

vpc_cidr1 = "10.11.0.0/16"
vpc_cidr2 = "10.12.0.0/16"
subnet_cidrs_db_primary = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
subnet_cidrs_db_secondary = ["10.12.1.0/24", "10.12.2.0/24", "10.12.3.0/24"]
subnet_cidrs_app_primary = ["10.11.11.0/24"] # "10.11.12.0/24", "10.11.13.0/24"] only 1 app subnet for simplicity
subnet_cidrs_app_secondary = ["10.12.11.0/24"] # "10.12.12.0/24", "10.12.13.0/24"] only 1 app subnet for simplicity


postgres_instances_primary = {
    db1 = {
        name   = "postgres-primary-1"
        zone   = "a"
    }
    db2 = {
        name   = "postgres-primary-2"
        zone   = "b"
    }
}

postgres_instances_secondary = {
    db2 = {
        name = "postgres-secondary-1"
        zone = "a"
    }

}