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
}

# Create an ECS
resource "aws_ecs_cluster" "main" {
    name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "web" {
    family                   = "web-app"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    memory = var.settings.web_app.memory
    cpu = var.settings.web_app.cpu

    container_definitions = jsonencode([
        {
            name = "web-app"
            image = var.settings.web_app.image
            essential = true
            portMappings = [
                {
                    containerPort = 8000
                    hostPort = 8000
                }
            ]
            environment = [
                {
                    name = "MYSQL_HOST"
                    value = aws_db_instance.main.address
                },
                {
                    name = "MYSQL_DB"
                    value = var.settings.database.db_name
                },
                {
                    name = "MYSQL_USER"
                    value = var.db_username
                },
                {
                    name = "MYSQL_PASSWORD"
                    value = var.db_password
                }
            ]
        }
    ])
}

resource "aws_ecs_service" "web" {
    name            = "web-app-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.web.arn
    desired_count   = var.settings.web_app.desired_count
    launch_type     = "FARGATE"

    network_configuration {
        subnets = [for subnet in aws_subnet.private_fargate : subnet.id]
        security_groups = [aws_security_group.web.id]
        assign_public_ip = false
    }
}

# Create a load balancer
resource "aws_lb" "main" {
    name               = "web-app-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.web.id]
    subnets            = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_lb_target_group" "main" {
    name     = "web-app-tg"
    port     = 8000
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = 8000
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}

resource "aws_lb_target_group_attachment" "main" {
    target_group_arn = aws_lb_target_group.main.arn
    target_id        = aws_ecs_service.web.id
    port             = 8000
}









