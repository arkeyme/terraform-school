terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "EC2_Tutor"

  tags = {
    Name = "test"
  }
}

resource "aws_s3_bucket" "name" {
}

resource "aws_s3_bucket" "foo" {
  # (resource arguments)
}

output "aws_s3_bucket_id" {
  description = "ID of s3 bucket name"
  value       = aws_s3_bucket.name.id
}

output "aws_s3_bucket_foo_id" {
  description = "ID of s3 bucket foo"
  value       = aws_s3_bucket.foo.id
}
