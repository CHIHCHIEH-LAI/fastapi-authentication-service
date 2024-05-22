variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}

variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_count" {
    description = "Number of subnets"
    type = map(number)
    default = {
        public = 2,
        private_fargate = 2
        private_rds = 2
    }
}

variable "settings" {
    description = "Configuration settings"
    type = map(any)
    default = {
        "database" = {
            allocated_storage = 10
            engine = "mysql"
            engine_version = "8.0"
            instance_class = "db.m5.large"
            db_name = "accountDB"
            skip_final_snapshot = true
        }
    }
}

variable "db_username" {
    description = "Database username"
    type = string
    sensitive = true
}

variable "db_password" {
    description = "Database password"
    type = string
    sensitive = true
}

