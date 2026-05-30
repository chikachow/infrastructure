locals {
  active   = var.lifecycle_state == "active"
  retiring = var.lifecycle_state == "retiring"
  archived = var.lifecycle_state == "archived"

  manage_archive_preparation = local.active || local.retiring
  manage_security_settings   = local.active || local.retiring
}

resource "github_repository" "this" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  visibility   = var.visibility
  archived     = local.archived

  has_issues      = local.active ? var.has_issues : local.retiring ? false : null
  has_projects    = local.active ? var.has_projects : local.retiring ? false : null
  has_wiki        = local.active ? var.has_wiki : local.retiring ? false : null
  has_discussions = local.active ? var.has_discussions : local.retiring ? false : null

  allow_merge_commit = local.active ? var.allow_merge_commit : null
  allow_squash_merge = local.active ? var.allow_squash_merge : null
  allow_rebase_merge = local.active ? var.allow_rebase_merge : null
  allow_auto_merge   = local.active ? var.allow_auto_merge : null

  allow_update_branch         = local.active ? var.allow_update_branch : null
  allow_forking               = local.active ? var.allow_forking : local.retiring ? false : null
  archive_on_destroy          = true
  delete_branch_on_merge      = local.active ? var.delete_branch_on_merge : null
  is_template                 = local.active ? false : null
  web_commit_signoff_required = local.active ? false : null
  merge_commit_message        = local.active ? var.merge_commit_message : null
  merge_commit_title          = local.active ? var.merge_commit_title : null
  squash_merge_commit_message = local.active ? var.squash_merge_commit_message : null
  squash_merge_commit_title   = local.active ? var.squash_merge_commit_title : null

  topics = var.topics

  dynamic "security_and_analysis" {
    for_each = local.manage_security_settings ? [true] : []

    content {
      secret_scanning {
        status = var.secret_scanning_enabled ? "enabled" : "disabled"
      }

      secret_scanning_push_protection {
        status = var.secret_scanning_push_protection_enabled ? "enabled" : "disabled"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "this" {
  count = local.active ? 1 : 0

  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_repository_dependabot_security_updates" "this" {
  count = local.manage_security_settings ? 1 : 0

  repository = github_repository.this.name
  enabled    = var.dependabot_security_updates_enabled
}

resource "github_repository_vulnerability_alerts" "this" {
  count = local.manage_security_settings ? 1 : 0

  repository = github_repository.this.name
  enabled    = var.vulnerability_alerts_enabled
}
