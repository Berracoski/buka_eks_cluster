# EKS Cluster with Terraform

## Overview

This Terraform project provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster in the **us-east-1** region with the following components:

- **VPC with a /16 CIDR block (`10.0.0.0/16`):**
  - 3 public subnets (`/24` each), one per Availability Zone
  - Internet Gateway and Public Route Table for internet connectivity

- **EKS Cluster:**
  - Kubernetes version 1.30
  - Configured to use the custom VPC and subnets

- **Managed Node Group:**
  - 3 worker nodes using `t3.micro` EC2 instances
  - IAM role with necessary policies attached for worker nodes

- **IAM Roles and Policies:**
  - IAM role for the EKS control plane
  - IAM role for worker nodes
  - IAM role for Amazon EBS Container Storage Interface (CSI) driver
  - IAM OIDC provider integration for Kubernetes service account roles (IRSA)

- **EBS CSI Driver Addon:**
  - Enabled as an [EKS Addon](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
  - Allows dynamic provisioning of persistent storage with Amazon EBS volumes

- **Terraform Backend:**
  - Terraform state is stored remotely in an S3 bucket with server-side encryption enabled
  - Native state locking using the S3 `use_lockfile` feature (Terraform >= 1.10) to prevent concurrent state operations

- **Kubernetes Nginx Deployment:**
  - Deployment of Nginx with 3 pods in the cluster
  - Exposed by a LoadBalancer Kubernetes service (provisions an AWS ELB automatically)

---

## ⚠️ Important Notice - Create the S3 Bucket Before Using the Backend

> **You must create the S3 bucket used for Terraform remote state storage before running `terraform init` with the S3 backend configured.**  
>
> Terraform will **NOT** automatically create the S3 bucket specified in your `backend.tf` configuration. If the bucket does not exist, `terraform init` will fail.  
>
> The S3 bucket should have:
> - **A globally unique name**
> - **Versioning enabled** (to protect your state files from accidental overwrite)
> - **Encryption enabled** (recommended for security)  
>
> You can create this bucket manually via:
> - AWS Console
> - AWS CLI
> - Or a separate Terraform configuration (typically recommended to keep this bootstrap resource separate from your main infra).  
>
> **Example AWS CLI commands to create the bucket:**
> ```
> aws s3api create-bucket --bucket your-unique-terraform-state-bucket --region us-east-1
> aws s3api put-bucket-versioning --bucket your-unique-terraform-state-bucket --versioning-configuration Status=Enabled
> ```
>
> After the bucket is ready and your backend configured, run `terraform init` to initialize the backend and migrate state if needed.

---

## File Structure

| File                 | Description                                              |
|----------------------|----------------------------------------------------------|
| `provider.tf`        | AWS and Kubernetes provider configurations               |
| `vpc.tf`             | VPC, subnets, internet gateway, and route table          |
| `iam.tf`             | IAM roles and policy attachments for EKS and CSI driver  |
| `eks-cluster.tf`     | EKS control plane cluster resource                        |
| `node-group.tf`      | Managed node group with t3.micro worker nodes             |
| `ebs-csi.tf`         | EBS CSI driver installed as an EKS addon                  |
| `k8s-provider.tf`    | Kubernetes provider configured to connect to EKS         |
| `nginx-deployment.tf`| Kubernetes Deployment resource for Nginx                  |
| `nginx-service.tf`   | Kubernetes Service of type LoadBalancer for Nginx        |
| `backend.tf`         | Terraform S3 backend configuration with native locking    |

---

## Prerequisites

- AWS CLI configured with credentials and permissions to manage EKS, IAM, VPC, and S3
- Terraform 1.10 or higher (for native S3 locking)
- AWS account with available service quotas for EC2 instances, EKS clusters, and networking

---

## How to Use

1. **Create the S3 bucket for backend state** (see Important Notice above).

2. **Initialize the Terraform project**
```bash
terraform init
```
This will initialize providers and configure the remote backend.

3. **Review the execution plan**
```bash
terraform plan
```
4. **Apply the Terraform configuration**
```bash
terraform apply
```
Confirm to proceed with resource creation.

5. **Access your Kubernetes cluster**

Update your `kubeconfig` to connect to the EKS cluster:
```bash
aws eks update-kubeconfig --region us-east-1 --name example-eks-cluster
```
6. **Verify Nginx Deployment**

After a few minutes, check that Nginx pods are running:
```bash
kubectl get pods -l app=nginx
```
And get the external LoadBalancer IP/hostname:
```bash
kubectl get svc nginx-service
```

Open the EXTERNAL-IP or hostname in your browser to access Nginx.

---

## Notes

- The S3 bucket for Terraform remote state **must exist before running** `terraform init`.
- The bucket should have **versioning and encryption** enabled for best practice.
- This setup assumes public subnets with internet access; for private subnets or other setups, additional networking config is needed.
- The EBS CSI driver addon enables persistent storage support for pods requiring EBS volumes.
- Nginx Kubernetes resources are managed via Terraform’s Kubernetes provider integrated with the EKS cluster.

---

## Cleanup

To delete all AWS resources and avoid ongoing costs:
```bash
terraform destroy
```
Confirm the prompt to proceed.

---

## References

- [Amazon EKS official documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Terraform AWS EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Amazon EBS CSI Driver for Kubernetes](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [Terraform S3 backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [Terraform Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)








