module "selvedge_repository" {
  source = "../../modules/github-repository"

  name           = "selvedge"
  visibility     = "public"
  default_branch = null

  manage_security_and_analysis        = false
  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "selvedge_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.selvedge_repository.name
}

module "selvedge_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.selvedge_repository.name
  name       = "ci"

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

module "selvedge_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.selvedge_repository.name
}

resource "github_repository_environment" "selvedge_production" {
  repository  = module.selvedge_repository.name
  environment = "production"
}

module "selvedge_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.selvedge_repository.name
}
