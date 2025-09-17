output "vpc_id" {
  value = aws_vpc.main.id
}
output "private_subnet_id"{
    value = aws_subnet.private.id
}
output "database_subnet_id" {
  value = aws_subnet.database.id
}
output "public_subnet_id" {
   value = aws_subnet.public.id
}
output "eip_id" {
    value = aws_eip.ec2-bastion-host-eip.id 
}
output "eip_allocation_id" {
  value = aws_eip.ec2-bastion-host-eip.allocation_id
}
output "eip_association_id" {
  value = aws_eip.ec2-bastion-host-eip.association_id
}
output "nat_gateway_id" {
    value = aws_nat_gateway.nat.id
}
output "bastion_host_sg_id" {
    value = aws_security_group.bastion_host_sg.id
}
output "db_subnet_group_name" {
    value = aws_db_subnet_group.main.name
}
output "eks_cluser_sg_id" {
    value = aws_security_group.eks_cluster.id
}