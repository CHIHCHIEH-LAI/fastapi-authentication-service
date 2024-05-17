terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.50"
        }
    }
    required_version = ">=1.8.3"
}

provider "aws" {
    region = var.region
    profile = "default"
}