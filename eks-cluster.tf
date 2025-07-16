resource "aws_eks_cluster" "main" {
  name     = "example-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  version = "1.30"
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
}

# Optionally output cluster details
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.main.name
}
