resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.this.name
    addon_name   = "vpc-cni"
}
resource "aws_eks_addon" "core_dns" {
    cluster_name = aws_eks_cluster.this.name
    addon_name   = "coredns"
}
resource "aws_eks_addon" "kube_proxy" {
    cluster_name = aws_eks_cluster.this.name
    addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "ebs_csi" {
    cluster_name = aws_eks_cluster.this.name
    addon_name   = "aws-ebs-csi-driver"
}