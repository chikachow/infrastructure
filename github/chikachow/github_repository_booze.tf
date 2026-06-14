module "booze_repository" {
  source = "../../modules/github-repository"

  name       = "booze"
  visibility = "public"

  has_issues    = true
  allow_forking = true
}

module "booze_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.booze_repository.name
}

module "booze_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.booze_repository.name
  name       = "ci"

  required_status_checks = [
    {
      context        = "ci"
      integration_id = local.github_actions_integration_id
    },
  ]
}
