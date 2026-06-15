module "cyspbot_repository" {
  source = "../../modules/github-repository"

  name       = "cyspbot"
  visibility = "public"
}

module "cyspbot_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cyspbot_repository.name
}

module "cyspbot_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cyspbot_repository.name
  name       = "ci"

  required_status_checks = [
    {
      context        = "ci"
      integration_id = local.github_actions_integration_id
    },
  ]
}

module "cyspbot_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.cyspbot_repository.name
}

resource "github_repository_environment" "cyspbot_production" {
  repository  = module.cyspbot_repository.name
  environment = "production"
}
