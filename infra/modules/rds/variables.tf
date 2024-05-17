variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "my-rds-instance"
}

variable "rds_engine" {
  description = "RDS engine type"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "accountDB"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "root"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "parameter_group_name" {
  description = "Parameter group name"
  type        = string
  default     = "default.mysql8.0"
}