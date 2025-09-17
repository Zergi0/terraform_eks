resource "aws_security_group" "db_sg" {
  name    = "db-sg"
  vpc_id  = var.vpc_id

    ingress {
        description     = "Allow EKS nodes to access db"
        from_port       = var.db_port
        to_port         = var.db_port
        protocol        = "tcp"
        security_groups = [var.eks_sg_node_id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_db_instance" "default" {
  allocated_storage       = 10
  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_pw
  parameter_group_name    = var.db_parameter_group
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.db_sg.id, var.eks_sg_node_id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
}
 resource "aws_db_subnet_group" "main" {
   name = "db-group"
   subnet_ids = [var.database_subnet_id, var.private_subnet_id ]
 }