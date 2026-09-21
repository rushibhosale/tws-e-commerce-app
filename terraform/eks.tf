module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = local.name
  kubernetes_version = "1.34"
  endpoint_public_access = true

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

# Add custom ingress rules to the Node Security Group
  node_security_group_additional_rules = {
    ingress_nodeport = {
      description                   = "Allow incoming traffic on standard NodePort range"
      protocol                      = "tcp"
      from_port                     = 30000
      to_port                       = 32767
      type                          = "ingress"
      cidr_blocks                   = ["0.0.0.0/0"] # WARNING: Opens to the whole internet. Restrict to a specific CIDR in production.
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {

    tws-demo-ng = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.large"]
      attach_cluster_primary_security_group = true
      capacity_type  = "SPOT"

      disk_size = 35 
      use_custom_launch_template = false  # Important to apply disk size!

      tags = {
        Name = "tws-demo-ng"
        Environment = "dev"
        ExtraTag = "e-commerce-app"
      }
    }
  }
 
  tags = local.tags


}

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}