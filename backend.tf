terraform {
  backend "s3" {
    bucket      = "your-unique-terraform-state-bucket"
    key         = "eks-cluster/terraform.tfstate"
    region      = "us-east-1"
    encrypt     = true
    use_lockfile = true
  }
}
