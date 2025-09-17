
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       =  "eu-west-2c" // fix

  tags = {
    Name = "bastion-host-subnet"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "database" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       =  "eu-west-2a"

  tags = {
    Name = "db-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       =  "eu-west-2b"

  tags = {
    Name = "private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route  {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion_host_sg" {
  description   = "EC2 Bastion Host Security Group"
  name          = "${var.project_name}-ec2-bastion-sg-${var.environment}"
  vpc_id        = aws_vpc.main.id
  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = [var.ec2-bastion-ingress-ip-1] 
    description   = "Open to Public Internet"
  }
  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    ipv6_cidr_blocks  = ["::/0"]
    description       = "IPv6 route Open to Public Internet"
  }
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
    description   = "IPv4 route Open to Public Internet"
  }
  tags = {
    Name = "bastion-host-SG"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "ec2-bastion-host-eip" {
  instance  = var.bastion_host_id
  tags = {
    Name = "${var.project_name}-ec2-bastion-host-eip-${var.environment}"
  }
  depends_on = [ aws_internet_gateway.this ]
}
resource "aws_eip" "nat-gateway-eip" {
  tags = {
    Name = "${var.project_name}-nat-eip-${var.environment}"
  }
  depends_on = [ aws_internet_gateway.this ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id   = aws_eip.nat-gateway-eip.allocation_id
  subnet_id       = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-eks-nat-gateway-${var.environment}"
  }  
  depends_on = [aws_internet_gateway.this]
}
resource "aws_eip_association" "ec2-bastion-host-eip-association" {
    instance_id     = var.bastion_host_id
    allocation_id   = aws_eip.ec2-bastion-host-eip.id
}