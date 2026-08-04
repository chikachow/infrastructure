module "cloudflare_workload_identity_issuer_repository" {
  source = "../../modules/github-repository"

  name           = "cloudflare-workload-identity-issuer"
  visibility     = "public"
  default_branch = null
}

module "cloudflare_workload_identity_issuer_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cloudflare_workload_identity_issuer_repository.name
}

module "cloudflare_workload_identity_issuer_ruleset_ci" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cloudflare_workload_identity_issuer_repository.name
  name       = "ci"

  required_status_checks = [
    {
      context        = "ci"
      integration_id = local.github_actions_integration_id
    },
  ]
}

module "cloudflare_workload_identity_issuer_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.cloudflare_workload_identity_issuer_repository.name
}

resource "github_repository_environment" "cloudflare_workload_identity_issuer_production" {
  repository  = module.cloudflare_workload_identity_issuer_repository.name
  environment = "production"
}
