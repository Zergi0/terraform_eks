resource "aws_key_pair" "bastion-host-key-pair" {
  key_name   = "${keyname}"
  public_key = file("${path.module}${var.ec2-bastion-public-key-path}")
}

resource "aws_subnet" "ec2-bastion-subnet" {
  vpc_id                  = module.networking.aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"

  tags = {
    Name = "bastion-host-subnet"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_security_group" "ec2-bastion-sg" {
  description = "EC2 Bastion Host Security Group"
  name = "test-ec2-bastion-sg-${var.environment}"
  vpc_id = module.networking.aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ec2-bastion-ingress-ip-1]
    description = "Open to Public Internet"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = ["::/0"]
    description = "IPv6 route Open to Public Internet"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "IPv4 route Open to Public Internet"
  }
  tags = {
    Name = "bastikon-host-SG"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.ec2-bastion-host-eip.allocation_id
  subnet_id = aws_subnet.ec2-bastion-subnet.id

  tags = {
    Name = "eks-nat-gateway"
  }  
  depends_on = [aws_internet_gateway.this]
}

resource "aws_internet_gateway" "this" {
  vpc_id = module.networking.aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = module.networking.aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.ec2-bastion-subnet.id
  route_table_id = aws_route_table.public.id
}

## EC2 Bastion Host Elastic IP
resource "aws_eip" "ec2-bastion-host-eip" {
    domain = "vpc"
    tags = {
    Name = "test-ec2-bastion-host-eip-${var.environment}"
    }
    depends_on = [ aws_internet_gateway.this ]
}

resource "aws_eip_association" "ec2-bastion-host-eip-association" {
    instance_id = aws_instance.ec2-bastion-host.id
    allocation_id = aws_eip.ec2-bastion-host-eip.id
}

resource "aws_instance" "ec2-bastion-host" {
    ami                     = "ami-0b9dd1f70861d4721"
    instance_type           = "t2.micro"
    key_name                = aws_key_pair.bastion-host-key-pair.key_name
    vpc_security_group_ids  = [ aws_security_group.ec2-bastion-sg.id ]
    subnet_id = aws_subnet.ec2-bastion-subnet.id
    associate_public_ip_address = false
    user_data                   = file(var.bastion-bootstrap-script-path)
    root_block_device {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
      encrypted = true
      tags = {
        Name = "test-ec2-bastion-host-root-volume-${var.environment}"
      }
    }
    tags = {
        Name = "test-ec2-bastion-host-${var.environment}"
    }
    lifecycle {
      ignore_changes = [ 
        associate_public_ip_address,
       ]
    }
}