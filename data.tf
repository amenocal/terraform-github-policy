data "github_repository" "actions_selected_repositories" {
    for_each = toset(local.actions_settings["enabled-repositories"])
    full_name = "${var.owner}/${each.value}"
}