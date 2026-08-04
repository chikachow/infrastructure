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

module "terraform_provider_contentful_ruleset_require_lint" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_contentful_repository.name
  name       = "Require lint"

  bypass_actors = [
    {
      actor_id    = local.github_repository_role_maintain_id
      actor_type  = "RepositoryRole"
      bypass_mode = "pull_request"
    },
  ]

  required_status_checks = {
    lint = local.github_actions_integration_id
  }
}

module "terraform_provider_contentful_ruleset_require_passing_tests" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_contentful_repository.name
  name       = "Require passing tests"

  bypass_actors = [
    {
      actor_id    = local.github_repository_role_maintain_id
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    },
  ]

  required_status_checks = {
    "testaccmocked (1.14.*)"      = local.github_actions_integration_id
    "testacc (1.14.*)"            = local.github_actions_integration_id
    "testaccmocked (1.13.*)"      = local.github_actions_integration_id
    test                          = local.github_actions_integration_id
    contentful-management-go-test = local.github_actions_integration_id
  }
}

module "terraform_provider_contentful_ruleset_require_test_coverage" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_contentful_repository.name
  name       = "Require test coverage"

  bypass_actors = [
    {
      actor_id    = local.github_repository_role_maintain_id
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    },
  ]

  required_status_checks = {
    "codecov/project" = local.codecov_integration_id
  }
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
