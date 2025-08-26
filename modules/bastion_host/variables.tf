# EC2 Bastion Host variables
variable "ec2-bastion-public-key-path" {
  type = string
}

variable "ec2-bastion-private-key-path" {
  type = string
  sensitive = true
}

variable "ec2-bastion-ingress-ip-1" {
  type = string
  sensitive = true
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
variable "vpc_id" {
  type = string
}