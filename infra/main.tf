module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source = "./modules/rds"
}

resource "null_resource" "init_db" {
  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${module.rds.this_rds_instance_endpoint} -P 3306 -u ${module.rds.db_username} -p${module.rds.db_password} ${module.rds.db_name} < ${var.db_init_script_path}
    EOT
  }

  depends_on = [module.rds]
}
