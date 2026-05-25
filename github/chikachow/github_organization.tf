resource "github_organization_settings" "chikachow" {
  billing_email = "s@chikachow.org"

  default_repository_permission = "read"

  has_organization_projects = true
  has_repository_projects   = true

  members_can_create_repositories          = true
  members_can_create_public_repositories   = true
  members_can_create_private_repositories  = true
  members_can_create_internal_repositories = false
  members_can_create_pages                 = true
  members_can_fork_private_repositories    = false

  web_commit_signoff_required = false
}

resource "github_actions_organization_permissions" "chikachow" {
  enabled_repositories = "all"
  allowed_actions      = "all"
  sha_pinning_required = false
}

resource "github_actions_organization_workflow_permissions" "chikachow" {
  organization_slug = local.github_owner

  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}
