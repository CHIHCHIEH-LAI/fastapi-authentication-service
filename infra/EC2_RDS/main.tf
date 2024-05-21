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
    cidr_block = var.public_subnet_cidr_blocks[count.index]
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
    cidr_block = var.private_subnet_cidr_blocks[count.index]
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
        from_port = 8000
        to_port = 8000
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

# Create a db subnet group
resource "aws_db_subnet_group" "main_db_subnet_group" {
    name = "main_db_subnet_group"
    subnet_ids = [for subnet in aws_subnet.main_private_subnet : subnet.id]
}

# create a MySQL RDS instance
resource "aws_db_instance" "main_db" {
    allocated_storage = var.settings.database.allocated_storage
    engine = var.settings.database.engine
    engine_version = var.settings.database.engine_version
    instance_class = var.settings.database.instance_class
    db_name = var.settings.database.db_name
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.main_db_subnet_group.id
    vpc_security_group_ids = [aws_security_group.main_db_sg.id]
    skip_final_snapshot = var.settings.database.skip_final_snapshot
}

# Create a EC2 instance
resource "aws_key_pair" "main_kp" {
    key_name = "main_kp"
    public_key = file("main_kp.pub")
}

data "aws_ami" "ubuntu" {
    most_recent = "true"
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "main_web" {
    count = var.settings.web_app.count
    ami = data.aws_ami.ubuntu.id
    instance_type = var.settings.web_app.instance_type
    subnet_id = aws_subnet.main_public_subnet[count.index].id
    key_name = aws_key_pair.main_kp.key_name
    vpc_security_group_ids = [aws_security_group.main_web_sg.id]
    tags = {
        Name = "main_web_${count.index}"
    }
}

resource "aws_eip" "main_web_eip" {
    count = var.settings.web_app.count
    instance = aws_instance.main_web[count.index].id
    tags = {
        Name = "main_web_eip_${count.index}"
    }
}

