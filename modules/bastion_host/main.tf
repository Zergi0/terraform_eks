resource "aws_key_pair" "bastion-host-key-pair" {
  key_name   = "${var.keyname}"
  public_key = file("${var.ec2-bastion-public-key-path}")
}

resource "aws_instance" "ec2-bastion-host" {
  ami                         = "ami-0b9dd1f70861d4721"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion-host-key-pair.key_name
  vpc_security_group_ids      = [ var.bastion_host_sg_id ]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = false
  //user_data                   = file(var.bastion-bootstrap-script-path)
  root_block_device {
    volume_size = 8
    delete_on_termination = true
    volume_type = "gp2"
    encrypted = true
    tags = {
      Name = "${var.project_name}-ec2-bastion-host-root-volume-${var.environment}"
    }
  }
  lifecycle {
    ignore_changes = [ 
      associate_public_ip_address,
     ]
   }
   tags = {
      Name = "${var.project_name}-ec2-bastion-host-${var.environment}"
   }
}