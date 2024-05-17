module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "6.6.0"

  identifier = var.rds_identifier
  engine     = var.rds_engine
  engine_version = var.rds_engine_version
  
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  allocated_storage = var.allocated_storage

  instance_class = var.db_instance_class

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name = module.vpc.database_subnet_group_name

  parameter_group_name = var.parameter_group_name

  tags = {
    Name = "my-rds-instance"
    Environment = "dev"
  }
}