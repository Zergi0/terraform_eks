module "bastion_host" {
    source = "./modules/bastion_host"
    project_name = project_name
    keyname = keyname
    environment = environment
    ec2-bastion-public-key-path = ec2-bastion-public-key-path
    ec2-bastion-ingress-ip-1 = ec2-bastion-ingress-ip-1
    ec2-bastion-private-key-path = ec2-bastion-private-key-path
    vpc_id = module.networking.vpc_id
}

module "networking" {
  source = "./modules/networking"
  eip_id = module.bastion_host.eip_id
  bastion_host_subnet_id = module.bastion_host.bastion_host_subnet_id
  eip_allocation_id = module.bastion_host.eip_allocation_id
  aws_nat_gateway_id =  module.bastion_host.nat_gateway_id

}

module "eks" {
    source = "./modules/eks"
    bastion_host_subnet_id = module.bastion_host.bastion_host_subnet_id
    private_subnet_id = module.networking.private_subnet_id
    eip_id = module.bastion_host.eip_id
    vpc_id = module.networking.vpc_id
}
