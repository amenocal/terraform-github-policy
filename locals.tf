locals {
  yaml_config = yamldecode(file("${path.module}/${var.config_file}"))
  admins      = try(toset(local.yaml_config["admins"]), toset([]))
  settings    = local.yaml_config["settings"]
  actions_settings = local.yaml_config["actions-settings"]
    allowed_actions_config = { for item in local.actions_settings["allowed-actions-config"] : keys(item)[0] => values(item)[0] }
  ruleset_settings = { for ruleset in local.yaml_config["rulesets"]: ruleset.name => ruleset }
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
  value = var.owner
}