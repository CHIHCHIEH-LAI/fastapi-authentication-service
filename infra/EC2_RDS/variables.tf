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
        public = 1,
        private = 2
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
        },
        "web_app" = {
            count = 1
            instance_type = "t2.micro"
        }
    }
}

variable "public_subnet_cidr_blocks" {
    description = "Public subnet CIDR blocks"
    type = list(string)
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24"
    ]
}

variable "private_subnet_cidr_blocks" {
    description = "Private subnet CIDR blocks"
    type = list(string)
    default = [
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24",
        "10.0.104.0/24"
    ]
}

variable "my_ip" {
    description = "My IP address"
    type = string
    sensitive = true
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




