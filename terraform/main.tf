terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
  }
  backend "s3" {
    bucket = "duyanh-terraform-state"
    key = "dev/iot-sns-sqs"
    region = "ap-southeast-1"
  }
}

provider aws {
  region = var.region
}


