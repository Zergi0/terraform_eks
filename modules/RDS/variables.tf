variable "database_subnet_id" {
    type = string
}
variable "private_subnet_id" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "eks_sg_node_id" {
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
    type        = string
    sensitive   = true
}
variable "db_parameter_group" {
    type = string
}
variable "project_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "db_subnet_group_name" {
    type = string
}
variable "db_sg_id" {
    type = string
}