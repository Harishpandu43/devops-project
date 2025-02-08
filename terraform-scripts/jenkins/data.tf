data "aws_eks_cluster" "cluster" {
  name = "myDevcluster"  
}

data "aws_eks_cluster_auth" "cluster" {
  name = "myDevcluster" 
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "current" {}
