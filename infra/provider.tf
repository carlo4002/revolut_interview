terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-3"
}


provider "aws" {
    alias  = "primary_region"
    region = var.region1
    # assume_role {
    #       role_arn = var.assume_role_arn
    # }
    profile = "infra"
}

provider "aws" {
    alias  = "secondary_region"
    region = var.region2
    # assume_role {
    #      role_arn = var.assume_role_arn
    # }
    profile = "infra"
}

