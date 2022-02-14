# DISCLAIMER: 
# Because I don't remember what resources/iam roles to attribute off the top
# of my head, I have used the sample (modified) provided by HashiCorp
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

# ---------------------------------
#          BOILERPLATE
# ---------------------------------
terraform {
  required_version = ">=0.12"
}

# leave provider empty to use environment variables
provider "aws" {
  region = "ca-central-1"
}

# ---------------------------------
#              IAM
# ---------------------------------
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_role.name
}

# ---------------------------------
#              EKS
# ---------------------------------
resource "aws_eks_cluster" "k8s" {
  name = "k8s-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.all.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]
}