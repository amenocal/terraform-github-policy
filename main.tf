module "organization" {
  source  = "mineiros-io/organization/github"
  version = "~> 0.9.0"

  settings = {
    company                                                      = try(local.settings["company"], "")
    billing_email                                                = try(local.settings["billing-email"], "")
    email                                                        = try(local.settings["email"], "")
    twitter_username                                             = try(local.settings["twitter-username"], "")
    name                                                         = try(local.settings["name"], "")
    description                                                  = try(local.settings["description"], "")
    has_organization_projects                                    = try(local.settings["organization-projects"], "")
    has_repository_projects                                      = try(local.settings["repository-projects"], "")
    default_repository_permissions                               = try(local.settings["base-permissions"], "read")
    members_can_create_repositories                              = try(local.settings["create-repositories"], true)
    members_can_create_public_repositories                       = try(local.settings["create-public-repositories"], true)
    members_can_create_private_repositories                      = try(local.settings["create-private-repositories"], true)
    members_can_create_internal_repositories                     = try(local.settings["create-internal-repositories"], true)
    members_can_create_pages                                     = try(local.settings["create-pages"], true)
    members_can_create_public_pages                              = try(local.settings["create-public-pages"], true)
    members_can_create_private_pages                             = try(local.settings["create-private-pages"], true)
    members_can_fork_private_repositories                        = try(local.settings["fork-private-repositories"], false)
    web_commit_signoff_required                                  = try(local.settings["web-commit-signoff-required"], false)
    advanced_security_enabled_for_new_repositories               = try(local.settings["advanced-security-enabled-for-new-repositories"], false)
    dependabot_alerts_enabled_for_new_repositories               = try(local.settings["dependabot-alerts-enabled-for-new-repositories"], false)
    dependabot_security_updates_enabled_for_new_repositories     = try(local.settings["dependabot-security-updates-enabled-for-new-repositories"], false)
    dependency_graph_enabled_for_new_repositories                = try(local.settings["dependency-graph-enabled-for-new-repositories"], false)
    secret_scanning_enabled_for_new_repositories                 = try(local.settings["secret-scanning-enabled-for-new-repositories"], false)
    secret_scanning_push_protection_enabled_for_new_repositories = try(local.settings["secret-scanning-push-protection-enabled-for-new-repositories"], false)
  }

  admins = local.admins

}

resource "github_actions_organization_permissions" "actions_permissions" {
  allowed_actions = local.actions_settings["allows-actions"]
  enabled_repositories = local.actions_settings["repository-policy"]
  allowed_actions_config {
    github_owned_allowed = local.allowed_actions_config["github-owned"]
    patterns_allowed = local.allowed_actions_config["patterns-allowed"]
    verified_allowed = local.allowed_actions_config["verified-allowed"]
  }
  enabled_repositories_config {
      repository_ids = [for repo in values(data.github_repository.actions_selected_repositories) : repo.repo_id]
  }
}
