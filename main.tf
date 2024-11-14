terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  alias = "S3"
  shared_config_files = [var.tfc_aws_dynamic_credentials.aliases["S3"].shared_config_file]
}

provider "aws" {
  region = "us-west-2"
  alias = "EC2"
  shared_config_files = [var.tfc_aws_dynamic_credentials.aliases["EC2"].shared_config_file]
}

variable "tfc_aws_dynamic_credentials" {
  description = "Object containing AWS dynamic credentials configuration"
  type = object({
    default = object({
      shared_config_file = string
    })
    aliases = map(object({
      shared_config_file = string
    }))
  })
}

resource "aws_s3_bucket" "helen-demo-2024-11-14" {
  bucket = "2024-11-14-helen-demo"
  provider = aws.S3
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
  provider = aws.EC2
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  provider = aws.EC2
}
