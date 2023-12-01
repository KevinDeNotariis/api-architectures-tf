terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }

  required_version = "~> 1"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      owner = "kevin de notariis"
      repo  = "tmnl-apis"
    }
  }
}
