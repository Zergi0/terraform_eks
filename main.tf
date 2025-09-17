module "bastion_host" {
    source                          = "./modules/bastion_host"
    project_name                    = var.project_name
    keyname                         = var.keyname
    environment                     = var.environment
    ec2-bastion-public-key-path     = var.bastion_host_public_key
    ec2-bastion-ingress-ip-1        = var.bastion_host_ingress_ip
    vpc_id                          = module.networking.vpc_id
}

module "networking" {
  source                    = "./modules/networking"
  eip_id                    = module.bastion_host.eip_id
  bastion_host_subnet_id    = module.bastion_host.bastion_host_subnet_id
  eip_allocation_id         = module.bastion_host.eip_allocation_id
  aws_nat_gateway_id        =  module.bastion_host.nat_gateway_id

}

module "eks" {
    source                  = "./modules/eks"
    bastion_host_subnet_id  = module.bastion_host.bastion_host_subnet_id
    private_subnet_id       = module.networking.private_subnet_id
    eip_id                  = module.bastion_host.eip_id
    vpc_id                  = module.networking.vpc_id
}

module "database" {
    source                  = "./modules/database"
    database_subnet_id      = module.networking.database_subnet_id
    private_subnet_id       = module.networking.private_subnet_id
    vpc_id                  = module.networking.vpc_id
    eks_sg_node_id          = module.eks.eks_sg_node_id
    db_port                 = var.db_port
    db_name                 = var.db_name
    db_engine               = var.db_engine
    db_engine_version       = var.db_engine_version
    db_username             = var.db_username
    db_pw                   = var.db_pw
    db_parameter_group      = var.db_parameter_group
}