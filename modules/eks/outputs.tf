output "eks_sg_node_id" {
    value = aws_security_group.eks_nodes.id
}