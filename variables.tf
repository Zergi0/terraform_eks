
variable "bastion_host_public_key" {
    type = string
}
variable "bastion_host_private_key" {
    type = string
    sensitive = true
}
variable "keyname" {
    type = string
} 
variable "bastion_host_ingress_ip" {
    type = string
    sensitive = true
}
variable "environment" {
    type = string
}
variable "project_name" {
    type = string
}
variable "db_port" {
    type = string
}
variable "db_name" {
    type = string
}
variable "db_engine" {
    type = string
}
variable "db_engine_version" {
    type = string
}
variable "db_username" {
    type = string
    sensitive = true
}
variable "db_pw" {
    type = string
    sensitive = true
}
variable "db_parameter_group" {
    type = string
}