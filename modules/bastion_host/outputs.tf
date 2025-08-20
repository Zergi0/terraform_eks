
output "bastion_host_subnet_id" {
   value = aws_subnet.ec2-bastion-subnet.id
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
