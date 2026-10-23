module "terraform_provider_contentful_repository" {
  source = "../../modules/github-repository"

  name       = "terraform-provider-contentful"
  visibility = "public"

  homepage_url = "https://registry.terraform.io/providers/cysp/contentful/latest"
  has_issues   = true
}

module "terraform_provider_contentful_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.terraform_provider_contentful_repository.name
}

module "terraform_provider_contentful_status_rulesets" {
  for_each = {
    require_lint = {
      name = "Require lint"
      bypass_actors = [
        local.github_repository_role_maintain_pull_request_bypass_actor,
      ]
      required_status_checks = {
        lint = local.github_actions_integration_id
      }
    }
    require_passing_tests = {
      name = "Require passing tests"
      bypass_actors = [
        local.github_repository_role_maintain_always_bypass_actor,
      ]
      required_status_checks = {
        "testaccmocked (1.16.*)"      = local.github_actions_integration_id
        "testacc (1.16.*)"            = local.github_actions_integration_id
        "testaccmocked (1.15.*)"      = local.github_actions_integration_id
        test                          = local.github_actions_integration_id
        contentful-management-go-test = local.github_actions_integration_id
      }
    }
    require_test_coverage = {
      name = "Require test coverage"
      bypass_actors = [
        local.github_repository_role_maintain_always_bypass_actor,
      ]
      required_status_checks = {
        "codecov/project" = local.codecov_integration_id
      }
    }
  }

  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_contentful_repository.name
  name       = each.value.name

  bypass_actors          = try(each.value.bypass_actors, [])
  required_status_checks = each.value.required_status_checks
}

module "terraform_provider_contentful_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.terraform_provider_contentful_repository.name
}

resource "github_actions_variable" "terraform_provider_contentful" {
  for_each = {
    CONTENTFUL_ENVIRONMENT_ID  = "master"
    CONTENTFUL_ORGANIZATION_ID = "2zuSjSO4A0e6GKBrhJRe2m"
    CONTENTFUL_SPACE_ID        = "0p38pssr0fi3"
    CYSPBOT_APP_ID             = local.cyspbot_github_app_id
  }

  repository    = module.terraform_provider_contentful_repository.name
  variable_name = each.key
  value         = each.value
}

resource "github_repository_environment" "terraform_provider_contentful_release" {
  for_each = toset(["release", "release-preparation"])

  repository        = module.terraform_provider_contentful_repository.name
  environment       = each.key
  can_admins_bypass = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "terraform_provider_contentful_release" {
  repository  = module.terraform_provider_contentful_repository.name
  environment = github_repository_environment.terraform_provider_contentful_release["release"].environment
  tag_pattern = "v*"
}

resource "github_repository_environment_deployment_policy" "terraform_provider_contentful_release_preparation" {
  repository     = module.terraform_provider_contentful_repository.name
  environment    = github_repository_environment.terraform_provider_contentful_release["release-preparation"].environment
  branch_pattern = "main"
}

resource "github_actions_environment_variable" "terraform_provider_contentful_release_app_client_id" {
  count = var.terraform_provider_contentful_release_app == null ? 0 : 1

  repository    = module.terraform_provider_contentful_repository.name
  environment   = github_repository_environment.terraform_provider_contentful_release["release-preparation"].environment
  variable_name = "RELEASE_APP_CLIENT_ID"
  value         = var.terraform_provider_contentful_release_app.client_id
}

resource "github_repository_ruleset" "terraform_provider_contentful_release_tag_creation" {
  repository  = module.terraform_provider_contentful_repository.name
  name        = "Restrict release tag creation"
  target      = "tag"
  enforcement = "active"

  # Preserve the existing maintainer's ability to create recovery tags.
  bypass_actors {
    actor_id    = 742696
    actor_type  = "User"
    bypass_mode = "always"
  }

  dynamic "bypass_actors" {
    for_each = var.terraform_provider_contentful_release_app == null ? [] : [var.terraform_provider_contentful_release_app]

    content {
      actor_id    = bypass_actors.value.app_id
      actor_type  = "Integration"
      bypass_mode = "always"
    }
  }

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    creation = true
  }

  # Install immutable tag protection before narrowing the imported combined rule.
  depends_on = [github_repository_ruleset.terraform_provider_contentful_release_tag_mutation]
}

resource "github_repository_ruleset" "terraform_provider_contentful_release_tag_mutation" {
  repository  = module.terraform_provider_contentful_repository.name
  name        = "Prevent release tag changes"
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    update   = true
    deletion = true
  }
}
