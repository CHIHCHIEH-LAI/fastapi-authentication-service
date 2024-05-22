data "aws_availability_zones" "available" {
    state = "available"
}

# Create a VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
}

# Create subnets
resource "aws_subnet" "public" {
    count = var.subnet_count.public
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "private_fargate" {
    count = var.subnet_count.private_fargate
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.subnet_count.public)
    availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "private_rds" {
    count = var.subnet_count.private_rds
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.subnet_count.public + var.subnet_count.private_fargate)
    availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

# Create route tables
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "public" {
    count = var.subnet_count.public
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_fargate" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_fargate" {
    count = var.subnet_count.private_fargate
    subnet_id = aws_subnet.private_fargate[count.index].id
    route_table_id = aws_route_table.private_fargate.id
}

resource "aws_route_table" "private_rds" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_rds" {
    count = var.subnet_count.private_rds
    subnet_id = aws_subnet.private_rds[count.index].id
    route_table_id = aws_route_table.private_rds.id
}

# Create security groups
resource "aws_security_group" "web" {
    vpc_id = aws_vpc.main.id
    ingress {
        description = "Allow HTTP traffic"
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.main.id
    ingress {
        description = "Allow MySQL traffic"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web.id]
    }
}

# Create a RDS
resource "aws_db_subnet_group" "main" {
    subnet_ids = [for subnet in aws_subnet.private_rds : subnet.id]
}

resource "aws_db_instance" "main" {
    allocated_storage = var.settings.database.allocated_storage
    engine = var.settings.database.engine
    engine_version = var.settings.database.engine_version
    instance_class = var.settings.database.instance_class
    db_name = var.settings.database.db_name
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.main.id
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    skip_final_snapshot = var.settings.database.skip_final_snapshot

    depends_on = [aws_db_subnet_group.main]
}

# Create an ECS
resource "aws_ecs_cluster" "main" {
    name = "ecs-cluster"
}







