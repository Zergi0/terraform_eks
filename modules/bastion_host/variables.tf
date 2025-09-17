variable "ec2-bastion-public-key-path" {
    type = string
}
variable "project_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "keyname" {
    type = string
}
variable "public_subnet_id" {
    type = string
}
variable "bastion_host_sg_id" {
    type = string
}