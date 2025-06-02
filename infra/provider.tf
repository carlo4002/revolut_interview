provider "aws" {
  region = var.region1
  assume_role {
    role_arn = var.assume_role_arn
  }
  alias = "primary_region"
}

provider "aws" {
  region = var.region2
  assume_role {
    role_arn = var.assume_role_arn
  }
  alias = "secondary_region"
}