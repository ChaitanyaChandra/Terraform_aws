terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }

  backend "s3" {
    bucket = "terraform-course-cloudcasts"
    key    = "cloudcasts/terraform.tfstate"
    profile = "cloudcasts"
    region  = "us-east-2"
    dynamodb_table = "cloudcasts-terraform-course"
  }
}

provider "aws" {
  profile = "cloudcasts"
  region  = "us-east-2"
}

variable infra_env {
  type = string
  description = "infrastructure environment"
}

variable default_region {
  type = string
  description = "the region this infrastructure is in"
  default = "us-east-2"
}


data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["app"]
  }

  filter {
    name   = "tag:Project"
    values = ["cloudcast"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.infra_env]
  }

  owners = ["self"]
}

module "ec2_app" {
  source = "./modules/ec2"

  infra_env = var.infra_env
  infra_role = "web"
  instance_size = "t3.small"
  instance_ami = data.aws_ami.app.id
  # instance_root_device_size = 12
}

module "ec2_worker" {
  source = "./modules/ec2"

  infra_env = var.infra_env
  infra_role = "worker"
  instance_size = "t3.large"
  instance_ami = data.aws_ami.app.id
  instance_root_device_size = 20
}
