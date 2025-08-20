
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "main-subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"

  tags = {
    Name = "private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.aws_nat_gateway_id
  }
  tags = {
    Name = "private-route-table"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}