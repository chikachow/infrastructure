mock_provider "github" {}

run "private_active_defaults" {
  command = plan

  variables {
    name       = "private-active-defaults"
    visibility = "private"
  }

  assert {
    condition     = github_repository.this.visibility == "private" && !github_repository.this.archived
    error_message = "A private active repository must remain private and unarchived."
  }

  assert {
    condition     = length(github_repository.this.security_and_analysis) == 0
    error_message = "A private repository must leave security_and_analysis unmanaged by default."
  }

  assert {
    condition     = length(github_branch_default.this) == 1 && github_branch_default.this[0].branch == "main"
    error_message = "The default branch must be managed as main by default."
  }

  assert {
    condition = (
      !github_repository.this.allow_merge_commit &&
      !github_repository.this.allow_squash_merge &&
      github_repository.this.allow_rebase_merge &&
      github_repository.this.allow_auto_merge &&
      github_repository.this.allow_update_branch &&
      github_repository.this.delete_branch_on_merge &&
      github_repository.this.merge_commit_message == "PR_TITLE" &&
      github_repository.this.merge_commit_title == "MERGE_MESSAGE" &&
      github_repository.this.squash_merge_commit_message == "COMMIT_MESSAGES" &&
      github_repository.this.squash_merge_commit_title == "COMMIT_OR_PR_TITLE"
    )
    error_message = "The existing merge, branch update, branch deletion, and message/title defaults must be preserved."
  }

  assert {
    condition = (
      length(github_repository_dependabot_security_updates.this) == 1 &&
      github_repository_dependabot_security_updates.this[0].enabled &&
      length(github_repository_vulnerability_alerts.this) == 1 &&
      github_repository_vulnerability_alerts.this[0].enabled
    )
    error_message = "Dependabot security updates and vulnerability alerts must be enabled by default."
  }
}

run "public_security_defaults" {
  command = plan

  variables {
    name       = "public-security-defaults"
    visibility = "public"
  }

  assert {
    condition = (
      length(github_repository.this.security_and_analysis) == 1 &&
      one(github_repository.this.security_and_analysis).secret_scanning[0].status == "enabled" &&
      one(github_repository.this.security_and_analysis).secret_scanning_push_protection[0].status == "enabled"
    )
    error_message = "Public repositories must enable secret scanning and push protection by default."
  }
}

run "archived_repository" {
  command = plan

  variables {
    name            = "archived-repository"
    visibility      = "private"
    lifecycle_state = "archived"
  }

  assert {
    condition     = github_repository.this.archived
    error_message = "An archived lifecycle state must archive the repository."
  }
}

run "unmanaged_optional_resources" {
  command = plan

  variables {
    name                                = "unmanaged-optional-resources"
    visibility                          = "private"
    default_branch                      = null
    dependabot_security_updates_enabled = null
    vulnerability_alerts_enabled        = null
  }

  assert {
    condition = (
      length(github_branch_default.this) == 0 &&
      length(github_repository_dependabot_security_updates.this) == 0 &&
      length(github_repository_vulnerability_alerts.this) == 0
    )
    error_message = "A null default branch and null security settings must omit all three optional resources."
  }
}
