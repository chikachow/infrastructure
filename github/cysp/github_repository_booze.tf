module "booze_repository" {
  source = "../../modules/github-repository"

  name       = "booze"
  visibility = "public"

  has_issues    = true
  allow_forking = true
}

resource "github_actions_repository_permissions" "booze" {
  repository           = module.booze_repository.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}

module "booze_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.booze_repository.name
}

module "booze_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.booze_repository.name
  name       = "ci"

  strict_required_status_checks_policy = true

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

module "booze_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.booze_repository.name
}

module "booze_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.booze_repository.name
}
