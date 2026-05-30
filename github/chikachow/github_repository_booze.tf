resource "github_repository" "booze" {
  name       = "booze"
  visibility = "private"

  auto_init = true

  has_projects = false
  has_wiki     = false

  allow_merge_commit = false
  allow_squash_merge = false

  archive_on_destroy     = true
  delete_branch_on_merge = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "booze" {
  repository = github_repository.booze.name
  branch     = "main"
}

resource "github_repository_dependabot_security_updates" "booze" {
  repository = github_repository.booze.name
  enabled    = true
}

resource "github_repository_vulnerability_alerts" "booze" {
  repository = github_repository.booze.name
  enabled    = true
}
