module "cloudflare_workload_identity_repository" {
  source = "../../modules/github-repository"

  name           = "cloudflare-workload-identity"
  visibility     = "public"
  default_branch = null

  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "cloudflare_workload_identity_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cloudflare_workload_identity_repository.name
}

module "cloudflare_workload_identity_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cloudflare_workload_identity_repository.name
  name       = "ci"

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

module "cloudflare_workload_identity_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.cloudflare_workload_identity_repository.name
}

resource "github_repository_environment" "cloudflare_workload_identity_production" {
  repository  = module.cloudflare_workload_identity_repository.name
  environment = "production"
}
