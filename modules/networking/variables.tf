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
variable "server_location" {
    type = string
}
variable "db_port" {
    type = string
}