locals {
  owner  = "TheLeafVillage"
  yaml_config = yamldecode(file("${path.module}/${var.config_file}"))
  admins      = try(toset(local.yaml_config["admins"]), toset([]))
  settings    = local.yaml_config["settings"]
}


output "company" {
  value = local.yaml_config["settings"]["company"]
}

output "email" {
  value = local.yaml_config["settings"]["email"]
}

output "admins" {
  value = local.yaml_config["admins"]
}

output "organization" {
  value = local.owner
}