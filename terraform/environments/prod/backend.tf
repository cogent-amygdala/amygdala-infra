terraform {
	required_version = ">= 1.0"

    	required_providers {
      		aws = {
        		source  = "hashicorp/aws"
        		version = "~> 5.0"
      		}
    	}

    	# We'll set up S3 backend later after creating the bucket
    	# backend "s3" {
	# bucket = "amygdala-terraform-state"
    	# key    = "prod/terraform.tfstate"
    	# region = "us-east-1"
    	# }
}

provider "aws" {
	region = var.aws_region

    	default_tags {
      		tags = {
        		Environment = "Production"
        		ManagedBy   = "Terraform"
        		Project     = "Amygdala"
      		}
    	}
}
