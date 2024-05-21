output "web_public_ip" {
    description = "The public IP address of the web server"
    value = aws_eip.main_web_eip[0].public_ip
    depends_on = [aws_eip.main_web_eip]
}

output "web_public_dns" {
    description = "The public DNS name of the web server"
    value = aws_eip.main_web_eip[0].public_dns
    depends_on = [aws_eip.main_web_eip]
}

output "database_endpoint" {
    description = "The endpoint of the RDS database"
    value = aws_db_instance.main_db.address
}

output "database_port" {
    description = "The port of the RDS database"
    value = aws_db_instance.main_db.port
}