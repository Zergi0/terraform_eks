variable "ec2-bastion-ingress-ip-1" {
    type        = string
    sensitive   = true
}
variable "project_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "bastion_host_id" {
    type = string
}