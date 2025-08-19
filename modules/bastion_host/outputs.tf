
output "bastion_host_subnet_id" {
   value = aws_subnet.ec2-bastion-subnet.id
}
output "eip_id" {
    value = aws_eip.ec2-bastion-host-eip.id 
}