module "github_app_token_broker_repository" {
  source = "../../modules/github-repository"

  name           = "github-app-token-broker"
  visibility     = "public"
  default_branch = null

  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "github_app_token_broker_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.github_app_token_broker_repository.name
}

module "github_app_token_broker_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.github_app_token_broker_repository.name
  name       = "ci"

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

module "github_app_token_broker_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.github_app_token_broker_repository.name
}

resource "github_repository_environment" "github_app_token_broker_production" {
  repository  = module.github_app_token_broker_repository.name
  environment = "production"
}
