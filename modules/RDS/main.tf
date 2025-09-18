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
    db_subnet_group_name    = var.db_subnet_group_name
    
    tags = {
        Name = "${var.project_name}-rds-instance-${var.environment}"
    }
}