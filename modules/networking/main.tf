
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "database" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       =  "${var.server_location}a"

  tags = {
    Name = "RDS-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       =  "${var.server_location}b"

  tags = {
    Name = "${var.project_name}-private-subnet-${var.environment}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       =  "${var.server_location}c"

  tags = {
    Name = "${var.project_name}-bastion-host-subnet-${var.environment}"
    "kubernetes.io/role/elb" = "1"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route  {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-route-table-${var.environment}"
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
    Name = "${var.project_name}-bastion-host-SG-${var.environment}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-internet-gateway-${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.project_name}-public-route-table-${var.environment}"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "ec2-bastion-host-eip" {
  instance  = var.bastion_host_instance_id
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
    instance_id     = var.bastion_host_instance_id
    allocation_id   = aws_eip.ec2-bastion-host-eip.id
}

resource "aws_security_group" "db_sg" {
  name    = "db-sg"
  vpc_id  = aws_vpc.main.id

    ingress {
        description     = "Allow EKS nodes to access db"
        from_port       = var.db_port
        to_port         = var.db_port
        protocol        = "tcp"
        security_groups = [aws_security_group.eks_nodes.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.project_name}-rds-sg-${var.environment}"
    }
}

resource "aws_db_subnet_group" "main" {
   name = "db-group"
   subnet_ids = [aws_subnet.database.id, aws_subnet.private.id ]

    tags = {
        Name = "${var.project_name}-rds-subnet-group-${var.environment}"
    }
 }

 resource "aws_security_group" "eks_cluster" {
    vpc_id = aws_vpc.main.id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [aws_security_group.eks_nodes.id]
        description     = "Allow worker nodes to communicate with control plane"
    }
    tags = {
        Name = "${var.project_name}-eks-cluster-sg-${var.environment}"
    }
}

resource "aws_security_group" "eks_nodes" {
    vpc_id = aws_vpc.main.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self        = true
    }
    tags = {
        Name = "${var.project_name}-eks-nodes-sg-${var.environment}"
    }
}