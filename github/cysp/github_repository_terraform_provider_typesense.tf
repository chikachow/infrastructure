module "terraform_provider_typesense_repository" {
  source = "../../modules/github-repository"

  name       = "terraform-provider-typesense"
  visibility = "public"

  has_issues = true
}

resource "github_repository_ruleset" "terraform_provider_typesense_main" {
  repository = module.terraform_provider_typesense_repository.name

  name   = "main"
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

    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_approving_review_count   = 0
      required_review_thread_resolution = false
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      required_check {
        context        = "generate"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "test"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "lint"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "testacc (1.14.*)"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "testacc (1.15.*)"
        integration_id = local.github_actions_integration_id
      }
    }
  }
}

module "terraform_provider_typesense_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.terraform_provider_typesense_repository.name
}

resource "github_actions_variable" "terraform_provider_typesense_cyspbot_app_id" {
  repository    = module.terraform_provider_typesense_repository.name
  variable_name = "CYSPBOT_APP_ID"
  value         = local.cyspbot_github_app_id
}
