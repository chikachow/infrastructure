resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "public"

  has_issues      = false
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = false
  allow_rebase_merge = true
  allow_auto_merge   = false

  allow_update_branch         = false
  archive_on_destroy          = true
  delete_branch_on_merge      = true
  is_template                 = false
  web_commit_signoff_required = false
  merge_commit_message        = "PR_TITLE"
  merge_commit_title          = "MERGE_MESSAGE"
  squash_merge_commit_message = "COMMIT_MESSAGES"
  squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"

  topics = []

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }

    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "infrastructure" {
  repository = github_repository.infrastructure.name
  branch     = "main"
}

resource "github_repository_dependabot_security_updates" "infrastructure" {
  repository = github_repository.infrastructure.name
  enabled    = true
}

resource "github_repository_vulnerability_alerts" "infrastructure" {
  repository = github_repository.infrastructure.name
  enabled    = true
}

resource "github_repository_ruleset" "infrastructure_protect_default_branch" {
  repository = github_repository.infrastructure.name

  name   = "protect default branch"
  target = "branch"

  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
  }
}

removed {
  from = github_branch_protection.infrastructure_pull_request_approval

  lifecycle {
    destroy = false
  }
}

import {
  to = github_branch_protection_v3.infrastructure_pull_request_approval
  id = "infrastructure:main"
}

resource "github_branch_protection_v3" "infrastructure_pull_request_approval" {
  repository = github_repository.infrastructure.name
  branch     = github_branch_default.infrastructure.branch

  enforce_admins = false

  required_status_checks {
    strict = false
    checks = [
      "atlantis/apply:3852202",
    ]
  }

  required_pull_request_reviews {
    required_approving_review_count = 1

    bypass_pull_request_allowances {
      apps = [local.atlantis_github_app_slug]
    }
  }
}

resource "github_repository_ruleset" "infrastructure_tflint" {
  repository = github_repository.infrastructure.name

  name   = "tflint"
  target = "branch"

  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    required_status_checks {
      strict_required_status_checks_policy = false

      required_check {
        context        = "tflint"
        integration_id = 15368
      }
    }
  }
}
