resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "t3micro-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  ami_type       = "AL2_x86_64"

  labels = {
    role = "worker"
  }
}
