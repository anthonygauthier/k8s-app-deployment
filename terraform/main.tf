# DISCLAIMER: 
# To alleviate the time taken to complete the exercise, a modified version of 
# HashiCorp's eks example modules has been used.
#
# https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/main/vpc.tf
# https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/main/security-groups.tf
# https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/main/eks-cluster.tf
# https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/main/kubernetes.tf
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v17.24.0/examples/complete/main.tf

# ---------------------------------
#          BOILERPLATE
# ---------------------------------
terraform {
  required_version = ">=0.12"
}

provider "aws" {
  region = "ca-central-1"
}

locals {
  cluster_name = "eks-cluster"
}

# ---------------------------------
#             VPC
# ---------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["cac1-az1", "cac1-az2", "cac1-az4"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# ---------------------------------
#        SECURITY GROUPS
# ---------------------------------
resource "aws_security_group" "worker_group_1" {
  name_prefix = "worker_group_1"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

# ---------------------------------
#             EKS
# ---------------------------------
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.20"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id      = module.vpc.vpc_id
  subnets     = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker_group_1"
      instance_type                 = "t3.small"
      additional_security_group_ids = [aws_security_group.worker_group_1.id]
      asg_desired_capacity          = 2
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# ------------------------------
#             K8S
# ------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}