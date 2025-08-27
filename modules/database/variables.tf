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
    type        = string
    sensitive   = true
}
variable "db_parameter_group" {
    type = string
}