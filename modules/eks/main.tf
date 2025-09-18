resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role" "eks_node" {
  name = "eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
    role = aws_iam_role.eks_cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
    role = aws_iam_role.eks_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {    
    role = aws_iam_role.eks_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
    role = aws_iam_role.eks_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "this" {
    name = "eks-cluster"
    role_arn = aws_iam_role.eks_cluster.arn

    vpc_config {
      subnet_ids = [var.bastion_host_subnet_id, var.private_subnet_id]
      security_group_ids = [var.eks_cluster_sg_id]
    }
    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_service_policy
     ]
    tags = {
        Name = "${var.project_name}-eks-cluster-${var.environment}"
    }
}

resource "aws_eks_node_group" "backend" {
    cluster_name    = aws_eks_cluster.this.name
    node_group_name = "backend-nodes"
    node_role_arn   = aws_iam_role.eks_node.arn
    subnet_ids      = [var.private_subnet_id]

    instance_types =  ["t2.micro"]

    scaling_config {
      desired_size = 2
      max_size     = 3
      min_size     = 1
    }

    update_config {
      max_unavailable = 1
    }

    depends_on = [
      aws_iam_role_policy_attachment.eks_cni_policy,
      aws_iam_role_policy_attachment.eks_worker_policy,
      aws_iam_role_policy_attachment.ecr_read_policy,
    ]
    tags = {
        Name = "${var.project_name}-eks-backend-nodes-${var.environment}"
    }
}