module "bastion_host" {
    source                          = "./modules/bastion_host"
    project_name                    = var.project_name
    environment                     = var.environment
    keyname                         = var.keyname
    ec2-bastion-public-key-path     = var.bastion_host_public_key
    public_subnet_id                = module.networking.public_subnet_id
    bastion_host_sg_id              = module.networking.bastion_host_sg_id
}

module "networking" {
    source                    = "./modules/networking"
    ec2-bastion-ingress-ip-1  = var.bastion_host_ingress_ip
    project_name              = var.project_name
    environment               = var.environment
    bastion_host_id           = module.bastion_host.bastion_host_id
    server_location           = var.server_location
    db_port                   = var.db_port
}

module "eks" {
    source                  = "./modules/eks"
    project_name            = var.project_name
    environment             = var.environment
    bastion_host_subnet_id  = module.networking.public_subnet_id
    private_subnet_id       = module.networking.private_subnet_id
    eks_cluster_sg_id       = module.networking.eks_cluster_sg_id
}

module "RDS" {
    source                  = "./modules/RDS"
    project_name            = var.project_name
    environment             = var.environment
    database_subnet_id      = module.networking.database_subnet_id
    private_subnet_id       = module.networking.private_subnet_id
    vpc_id                  = module.networking.vpc_id
    db_subnet_group_name    = module.networking.db_subnet_group_name
    eks_sg_node_id          = module.eks.eks_sg_node_id
    db_name                 = var.db_name
    db_engine               = var.db_engine
    db_engine_version       = var.db_engine_version
    db_username             = var.db_username
    db_pw                   = var.db_pw
    db_parameter_group      = var.db_parameter_group
}