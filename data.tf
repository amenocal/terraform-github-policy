data "github_repository" "actions_selected_repositories" {
  for_each  = toset(local.actions_settings["enabled-repositories"])
  full_name = "${var.owner}/${each.value}"
}

data "github_team" "ruleset_teams" {
  for_each = toset(local.ruleset_teams)
  slug = each.value
}

data "github_app" "ruleset_apps" {
  for_each = toset(local.ruleset_github_apps)
  slug = each.value
}