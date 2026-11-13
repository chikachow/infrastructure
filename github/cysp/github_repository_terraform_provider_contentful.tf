module "terraform_provider_contentful_repository" {
  source = "../../modules/github-repository"

  name       = "terraform-provider-contentful"
  visibility = "public"

  homepage_url = "https://registry.terraform.io/providers/cysp/contentful/latest"
  has_issues   = true
}

resource "github_actions_repository_permissions" "terraform_provider_contentful" {
  repository           = module.terraform_provider_contentful_repository.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}

module "terraform_provider_contentful_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.terraform_provider_contentful_repository.name
}

module "terraform_provider_contentful_status_rulesets" {
  for_each = {
    require_ci = {
      name = "Require CI"
      bypass_actors = [
        local.github_repository_role_maintain_pull_request_bypass_actor,
      ]
      required_status_checks = {
        ci = local.github_actions_integration_id
      }
    }
    require_test_coverage = {
      name = "Require test coverage"
      bypass_actors = [
        local.github_repository_role_maintain_pull_request_bypass_actor,
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

module "terraform_provider_contentful_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.terraform_provider_contentful_repository.name
}

module "terraform_provider_contentful_ruleset_protect_release_tags" {
  source = "../../modules/github-repository-ruleset-protect-release-tags"

  repository = module.terraform_provider_contentful_repository.name
  bypass_actors = [
    {
      actor_id    = 742696
      actor_type  = "User"
      bypass_mode = "always"
    },
    {
      actor_id    = local.cyspbot_releaser_github_app_id
      actor_type  = "Integration"
      bypass_mode = "always"
    },
  ]
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

import {
  to = github_repository_environment.terraform_provider_contentful_release["release"]
  id = "terraform-provider-contentful:release"
}

import {
  to = github_repository_environment_deployment_policy.terraform_provider_contentful_release
  id = "terraform-provider-contentful:release:58073963"
}
