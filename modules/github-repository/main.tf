locals {
  default_security_and_analysis_enabled = var.visibility == "public" || var.security_and_analysis.advanced_security == true ? true : null
  effective_secret_scanning = (
    var.security_and_analysis.secret_scanning != null ? var.security_and_analysis.secret_scanning :
    var.security_and_analysis.secret_scanning_push_protection == true ? true :
    local.default_security_and_analysis_enabled
  )
  effective_security_and_analysis = {
    advanced_security                     = var.security_and_analysis.advanced_security
    secret_scanning                       = local.effective_secret_scanning
    secret_scanning_ai_detection          = var.security_and_analysis.secret_scanning_ai_detection
    secret_scanning_non_provider_patterns = var.security_and_analysis.secret_scanning_non_provider_patterns
    secret_scanning_push_protection = (
      var.security_and_analysis.secret_scanning_push_protection != null ? var.security_and_analysis.secret_scanning_push_protection :
      local.effective_secret_scanning == true ? true :
      local.effective_secret_scanning == false ? false :
      null
    )
  }

  manage_security_and_analysis = anytrue([
    for value in values(local.effective_security_and_analysis) : value != null
  ])
}

resource "github_repository" "this" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  visibility   = var.visibility
  archived     = var.lifecycle_state == "archived"

  has_issues      = var.has_issues
  has_projects    = var.has_projects
  has_wiki        = var.has_wiki
  has_discussions = var.has_discussions

  allow_merge_commit = var.allow_merge_commit
  allow_squash_merge = var.allow_squash_merge
  allow_rebase_merge = var.allow_rebase_merge
  allow_auto_merge   = var.allow_auto_merge

  allow_update_branch         = var.allow_update_branch
  allow_forking               = var.allow_forking
  archive_on_destroy          = true
  delete_branch_on_merge      = var.delete_branch_on_merge
  is_template                 = false
  web_commit_signoff_required = false
  merge_commit_message        = var.merge_commit_message
  merge_commit_title          = var.merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message
  squash_merge_commit_title   = var.squash_merge_commit_title

  topics = var.topics

  dynamic "security_and_analysis" {
    for_each = local.manage_security_and_analysis ? [true] : []

    content {
      dynamic "advanced_security" {
        for_each = local.effective_security_and_analysis.advanced_security == null ? [] : [local.effective_security_and_analysis.advanced_security]

        content {
          status = advanced_security.value ? "enabled" : "disabled"
        }
      }

      # code_security is not managed because provider v6.12.1 has schema only;
      # read/write support is tracked in:
      # https://github.com/integrations/terraform-provider-github/issues/2963
      # https://github.com/integrations/terraform-provider-github/pull/3431

      dynamic "secret_scanning" {
        for_each = local.effective_security_and_analysis.secret_scanning == null ? [] : [local.effective_security_and_analysis.secret_scanning]

        content {
          status = secret_scanning.value ? "enabled" : "disabled"
        }
      }

      dynamic "secret_scanning_ai_detection" {
        for_each = local.effective_security_and_analysis.secret_scanning_ai_detection == null ? [] : [local.effective_security_and_analysis.secret_scanning_ai_detection]

        content {
          status = secret_scanning_ai_detection.value ? "enabled" : "disabled"
        }
      }

      dynamic "secret_scanning_non_provider_patterns" {
        for_each = local.effective_security_and_analysis.secret_scanning_non_provider_patterns == null ? [] : [local.effective_security_and_analysis.secret_scanning_non_provider_patterns]

        content {
          status = secret_scanning_non_provider_patterns.value ? "enabled" : "disabled"
        }
      }

      dynamic "secret_scanning_push_protection" {
        for_each = local.effective_security_and_analysis.secret_scanning_push_protection == null ? [] : [local.effective_security_and_analysis.secret_scanning_push_protection]

        content {
          status = secret_scanning_push_protection.value ? "enabled" : "disabled"
        }
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "this" {
  count = var.default_branch == null ? 0 : 1

  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_repository_dependabot_security_updates" "this" {
  count = 1

  repository = github_repository.this.name
  enabled    = var.dependabot_security_updates_enabled
}

resource "github_repository_vulnerability_alerts" "this" {
  count = 1

  repository = github_repository.this.name
  enabled    = var.vulnerability_alerts_enabled
}
