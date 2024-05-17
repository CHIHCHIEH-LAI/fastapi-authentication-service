variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "db_init_script_path" {
  description = "The path to the SQL script to initialize the database"
  type        = string
  default     = "./init/init.sql"
}
