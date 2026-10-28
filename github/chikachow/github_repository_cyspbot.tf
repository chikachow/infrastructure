module "cyspbot_repository" {
  source = "../../modules/github-repository"

  name       = "cyspbot"
  visibility = "public"

  manage_security_and_analysis        = false
  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "cyspbot_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cyspbot_repository.name
}

module "cyspbot_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cyspbot_repository.name
  name       = "ci"

  required_status_checks = {
    ci                = local.github_actions_integration_id
    dependency-review = local.github_actions_integration_id
  }
}

module "cyspbot_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.cyspbot_repository.name
}

resource "github_repository_environment" "cyspbot_production" {
  repository  = module.cyspbot_repository.name
  environment = "production"
}

module "cyspbot_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.cyspbot_repository.name
}
