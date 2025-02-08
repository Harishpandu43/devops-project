locals {
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Environment = "dev"
  }
}