module "github_app_token_broker_action_repository" {
  source = "../../modules/github-repository"

  name        = "github-app-token-broker-action"
  description = "GitHub Action client for the GitHub App token broker"
  visibility  = "public"

  # The action-content task must seed the first main commit before Terraform
  # manages the repository's default branch and branch governance.
  default_branch = null

  has_issues    = true
  allow_forking = true

  # Preserve the organization/public-repository defaults during the empty
  # repository bootstrap; these can be made explicit after the first commit.
  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "github_app_token_broker_action_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.github_app_token_broker_action_repository.name
}

module "github_app_token_broker_action_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.github_app_token_broker_action_repository.name
  name       = "Require PR"

  depends_on = [
    module.github_app_token_broker_action_ruleset_required_status_checks,
  ]
}

module "github_app_token_broker_action_ruleset_required_status_checks" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.github_app_token_broker_action_repository.name
  name       = "Require status checks"

  required_status_checks = {
    check      = local.github_actions_integration_id
    actionlint = local.github_actions_integration_id
  }
}

module "github_app_token_broker_action_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.github_app_token_broker_action_repository.name
}
