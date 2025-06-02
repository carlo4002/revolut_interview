variable "region1" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "eu-west-3"
}

variable "region2" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "eu-west-1"
}

variable "assume_role_arn" {
    description = "The ARN of the role to assume"
    type        = string
}

variable ami_id_primary {
    description = "The AMI ID to use for the instance"
    type        = string
}

variable ami_id_secondary {
    description = "The AMI ID to use for the instance"
    type        = string
}

variable "vpc_cidr1" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "vpc_cidr2" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "cost_center" {
    description = "Cost center for the project"
    type        = number
}

variable "owner" {
    description = "Owner of the resources"
    type        = string
}

variable "subnet_cidrs_db_primary" {
  description = "List of CIDR blocks for db subnets in the primary region."
  type        = list(string)
}

variable "subnet_cidrs_db_secondary" {
  description = "List of CIDR blocks for db subnets in the secondary region."
  type        = list(string)
}

variable "subnet_cidrs_app_primary" {
  description = "List of CIDR blocks for apps subnets in the primary region."
  type        = list(string)
}

variable "subnet_cidrs_app_secondary" {
  description = "List of CIDR blocks for apps subnets in the secondary region."
  type        = list(string)
}

variable "availability_zones_primary" {
  description = "List of availability zones for the primary region."
  type        = list(string)   
}

variable "availability_zones_secondary" {
  description = "List of availability zones for the secondary region."
  type        = list(string)   
}

variable "postgres_instances_primary" {
  description = "List of PostgreSQL instance names in the primary region."
  type        = map(object({
    name = string
    zone = string
  }))
  default = {
    "db1" = { name = "db1", zone = "a" },
    "db2" = { name = "db2", zone = "b" },
    "db3" = { name = "db3", zone = "c" }
  }
}

variable "postgres_instances_secondary" {
  description = "List of PostgreSQL instance names in the secondary region."
  type        = map(object({
    name = string
    zone = string
  }))
    default = {
    "db1" = { name = "db1", zone = "a" },
    "db2" = { name = "db2", zone = "b" },
    "db3" = { name = "db3", zone = "c" }
  }
}