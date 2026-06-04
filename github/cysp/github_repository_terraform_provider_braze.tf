module "terraform_provider_braze_repository" {
  source = "../../modules/github-repository"

  name       = "terraform-provider-braze"
  visibility = "public"

  has_issues = true
}

module "terraform_provider_braze_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.terraform_provider_braze_repository.name
}

module "terraform_provider_braze_ruleset_require_passing_tests" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_braze_repository.name
  name       = "Require passing tests"

  bypass_actors = [
    {
      actor_id    = local.github_repository_role_admin_id
      actor_type  = "RepositoryRole"
      bypass_mode = "pull_request"
    },
  ]

  required_status_checks = [
    {
      context        = "test"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "testacc (1.13.*)"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "testacc (1.14.*)"
      integration_id = local.github_actions_integration_id
    },
  ]
}

module "terraform_provider_braze_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.terraform_provider_braze_repository.name
}

resource "github_actions_variable" "terraform_provider_braze_cyspbot_app_id" {
  repository    = module.terraform_provider_braze_repository.name
  variable_name = "CYSPBOT_APP_ID"
  value         = local.cyspbot_github_app_id
}
