module "cyspbot_app_token_action_repository" {
  source = "../../modules/github-repository"

  name       = "cyspbot-app-token-action"
  visibility = "public"

  has_issues    = true
  allow_forking = true
}

module "cyspbot_app_token_action_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cyspbot_app_token_action_repository.name
}

module "cyspbot_app_token_action_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.cyspbot_app_token_action_repository.name
  name       = "Require PR"

  depends_on = [
    module.cyspbot_app_token_action_ruleset_required_status_checks,
  ]
}

module "cyspbot_app_token_action_ruleset_required_status_checks" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cyspbot_app_token_action_repository.name
  name       = "Require status checks"

  required_status_checks = [
    {
      context        = "check"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "actionlint"
      integration_id = local.github_actions_integration_id
    },
  ]
}

module "cyspbot_app_token_action_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.cyspbot_app_token_action_repository.name
}
