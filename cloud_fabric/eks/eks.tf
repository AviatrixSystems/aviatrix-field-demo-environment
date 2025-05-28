module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {}
    #     eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_EXTERNALSNAT       = "true"
          AWS_VPC_K8S_CNI_EXCLUDE_SNAT_CIDRS = "10.0.0.0/8"
        }
      })
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = [var.cluster_instance_size]
  }

  eks_managed_node_groups = {
    ng_1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.cluster_instance_size]

      desired_size = 1
      min_size     = 1
      max_size     = 1

      subnet_ids = var.private_subnet_ids
    }
  }

  enable_irsa = true

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  create_cloudwatch_log_group = false
  #   create_kms_key              = false
  cluster_encryption_config = {}

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = ["view-nodes"]
      principal_arn     = var.aviatrix_aws_account_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
