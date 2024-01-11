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
  allowed_actions      = local.actions_settings["allows-actions"]
  enabled_repositories = local.actions_settings["repository-policy"]
  allowed_actions_config {
    github_owned_allowed = local.allowed_actions_config["github-owned"]
    patterns_allowed     = local.allowed_actions_config["patterns-allowed"]
    verified_allowed     = local.allowed_actions_config["verified-allowed"]
  }
  enabled_repositories_config {
    repository_ids = [for repo in values(data.github_repository.actions_selected_repositories) : repo.repo_id]
  }
}

resource "github_organization_ruleset" "ruleset_settings" {
  for_each    = local.ruleset_settings
  enforcement = each.value["enforcement"]
  target      = each.value["target"]
  name        = each.value["name"]

  dynamic "bypass_actors" {
    for_each =  each.value["bypass-actors"]
    content {
      actor_id    = (bypass_actors.value.actor-type == "OrganizationAdmin" ? 1 
                    : bypass_actors.value.actor-type == "RepositoryRole" ? 4 
                    : bypass_actors.value.actor-type == "Team" ? data.github_team.ruleset_teams[bypass_actors.value.actor].id 
                    : bypass_actors.value.actor-type == "Integration" ? data.github_app.ruleset_apps[bypass_actors.value.actor].id : 0)
      actor_type  = try(bypass_actors.value.actor-type, "")
      bypass_mode = try(bypass_actors.value.bypass-mode, "")
    }
  }

  rules {
    dynamic "branch_name_pattern" {
      for_each = try([each.value.rules["branch-name-pattern"]], [])
      content {
        name     = branch_name_pattern.value.name
        pattern  = branch_name_pattern.value.pattern
        operator = branch_name_pattern.value.operator
        negate   = branch_name_pattern.value.negate
      }
    }
    dynamic "commit_message_pattern" {
      for_each = try([each.value.rules["commit-message-pattern"]], [])
      content {
        name     = commit_message_pattern.value.name
        pattern  = commit_message_pattern.value.pattern
        operator = commit_message_pattern.value.operator
        negate   = commit_message_pattern.value.negate
      }
    }
    dynamic "commit_author_email_pattern" {
      for_each = try([each.value.rules["commit-author-email-pattern"]], [])
      content {
        name     = commit_author_email_pattern.value.name
        pattern  = commit_author_email_pattern.value.pattern
        operator = commit_author_email_pattern.value.operator
        negate   = commit_author_email_pattern.value.negate
      }
    }
    dynamic "committer_email_pattern" {
      for_each = try([each.value.rules["committer-email-pattern"]], [])
      content {
        name     = committer_email_pattern.value.name
        pattern  = committer_email_pattern.value.pattern
        operator = committer_email_pattern.value.operator
        negate   = committer_email_pattern.value.negate
      }
    }
    dynamic "pull_request" {
      for_each = try([each.value.rules["pull-request"]], [])
      content {
        dismiss_stale_reviews_on_push     = try(pull_request.value.dismiss_stale_reviews_on_push, false)
        require_code_owner_review         = try(pull_request.value.require_code_owner_review, false)
        require_last_push_approval        = try(pull_request.value.require_last_push_approval, false)
        required_approving_review_count   = try(pull_request.value.required_approving_review_count, 0)
        required_review_thread_resolution = try(pull_request.value.required_review_thread_resolution, false)
      }
    }

  }
}
