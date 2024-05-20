data "aws_availability_zones" "available" {
    state = "available"
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "main_vpc"
    }
}

# Create an internet gateway
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "main_igw"
    }
}

# Create a public subnet
resource "aws_subnet" "main_public_subnet" {
    count = var.subnet_count.public

    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.subnet_cidr_block.public[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "main_public_subnet_${count.index}"
    }
}

resource "aws_route_table" "main_public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }
}

resource "aws_route_table_association" "main_public_subnet_association" {
    count = var.subnet_count.public

    route_table_id = aws_route_table.main_public_rt.id
    subnet_id = aws_subnet.main_public_subnet[count.index].id
}

# Create two private subnets
resource "aws_subnet" "main_private_subnet" {
    count = var.subnet_count.private

    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.subnet_cidr_block.private[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "main_private_subnet_${count.index}"
    }
}

resource "aws_route_table" "main_private_rt" {
    vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table_association" "main_private_subnet_association" {
    count = var.subnet_count.private

    route_table_id = aws_route_table.main_private_rt.id
    subnet_id = aws_subnet.main_private_subnet[count.index].id
}

# Create a EC2 security group
resource "aws_security_group" "main_web_sg" {
    name = "main_web_sg"
    vpc_id = aws_vpc.main_vpc.id
    ingress {
        description = "Allow HTTP traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow SSH traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.my_ip}/32"]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "main_web_sg"
    }
}

# Create a RDS security group
resource "aws_security_group" "main_db_sg" {
    name = "main_db_sg"
    vpc_id = aws_vpc.main_vpc.id
    ingress {
        description = "Allow MySQL traffic"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.main_web_sg.id]
    }

    tags = {
        Name = "main_db_sg"
    }
}



