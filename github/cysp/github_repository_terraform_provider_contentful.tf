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

  required_status_checks = [
    {
      context        = "lint"
      integration_id = local.github_actions_integration_id
    },
  ]
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

  required_status_checks = [
    {
      context        = "testaccmocked (1.14.*)"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "testacc (1.14.*)"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "testaccmocked (1.13.*)"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "test"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "contentful-management-go-test"
      integration_id = local.github_actions_integration_id
    },
  ]
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

  required_status_checks = [
    {
      context        = "codecov/project"
      integration_id = local.codecov_integration_id
    },
  ]
}

module "terraform_provider_contentful_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.terraform_provider_contentful_repository.name
}

resource "github_actions_variable" "terraform_provider_contentful_contentful_environment_id" {
  repository    = module.terraform_provider_contentful_repository.name
  variable_name = "CONTENTFUL_ENVIRONMENT_ID"
  value         = "master"
}

resource "github_actions_variable" "terraform_provider_contentful_contentful_organization_id" {
  repository    = module.terraform_provider_contentful_repository.name
  variable_name = "CONTENTFUL_ORGANIZATION_ID"
  value         = "2zuSjSO4A0e6GKBrhJRe2m"
}

resource "github_actions_variable" "terraform_provider_contentful_contentful_space_id" {
  repository    = module.terraform_provider_contentful_repository.name
  variable_name = "CONTENTFUL_SPACE_ID"
  value         = "0p38pssr0fi3"
}

resource "github_actions_variable" "terraform_provider_contentful_cyspbot_app_id" {
  repository    = module.terraform_provider_contentful_repository.name
  variable_name = "CYSPBOT_APP_ID"
  value         = local.cyspbot_github_app_id
}
