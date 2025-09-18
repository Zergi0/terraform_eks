variable "bastion_host_subnet_id" {
  type = string
}
variable "private_subnet_id" {
  type = string
}
variable "project_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "eks_cluster_sg_id" {
    type = string
}