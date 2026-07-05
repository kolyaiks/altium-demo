terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "altium-demo-terraform-state-228305238849-us-east-1-an"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner = "kolyaiks"
      Repo  = "https://github.com/kolyaiks/altium-demo"
    }
  }
}