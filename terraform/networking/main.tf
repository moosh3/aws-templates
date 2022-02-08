terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

locals {
  management_account = "807936708916"
}

module "terraform_state_backend" {
  source     = "cloudposse/tfstate-backend/aws"
  version    = "0.38.1"
  namespace  = "alec"
  stage      = "network"
  name       = "terraform"
  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

resource "aws_iam_role" "terraform" {
  name = "TerraformCrossAccount"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.management_account}:root"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "network-firewall"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  intra_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name            = var.tgw_hub_name
  description     = "My TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  enable_auto_accept_shared_attachments = true # When "true" there is no need for RAM resources if using multiple AWS accounts

  vpc_attachments = {
    vpc1 = {
      vpc_id                                          = data.aws_vpc.default.id      # module.vpc1.vpc_id
      subnet_ids                                      = data.aws_subnet_ids.this.ids # module.vpc1.private_subnets
      dns_support                                     = true
      ipv6_support                                    = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "30.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    },
    vpc2 = {
      vpc_id     = data.aws_vpc.default.id      # module.vpc2.vpc_id
      subnet_ids = data.aws_subnet_ids.this.ids # module.vpc2.private_subnets

      tgw_routes = [
        {
          destination_cidr_block = "50.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "10.10.10.10/32"
        }
      ]
    },
  }

  ram_allow_external_principals = true
  ram_principals                = [307990089504]

  tags = {
    Purpose = "tgw-complete-example"
  }
}

module "tgw_peer" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.peer
  }

  name            = var.tgw_peer_name
  description     = "My TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  share_tgw                             = true
  create_tgw                            = false
  ram_resource_share_arn                = module.tgw.ram_resource_share_id
  enable_auto_accept_shared_attachments = true # When "true" there is no need for RAM resources if using multiple AWS accounts

  vpc_attachments = {
    vpc1 = {
      tgw_id                                          = module.tgw.ec2_transit_gateway_id
      vpc_id                                          = data.aws_vpc.default.id      # module.vpc1.vpc_id
      subnet_ids                                      = data.aws_subnet_ids.this.ids # module.vpc1.private_subnets
      dns_support                                     = true
      ipv6_support                                    = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      #      transit_gateway_route_table_id = "tgw-rtb-073a181ee589b360f"

      tgw_routes = [
        {
          destination_cidr_block = "30.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    },
  }

  ram_allow_external_principals = true
  ram_principals                = [307990089504]

  tags = {
    Purpose = "tgw-complete-example"
  }
}
