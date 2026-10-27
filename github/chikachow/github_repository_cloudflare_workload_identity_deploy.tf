module "cloudflare_workload_identity_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "cloudflare-workload-identity-deploy"
  description = "Private deployment pipeline for chikachow/cloudflare-workload-identity"
  visibility  = "private"

  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "cloudflare_workload_identity_deploy_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cloudflare_workload_identity_deploy_repository.name
}

module "cloudflare_workload_identity_deploy_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.cloudflare_workload_identity_deploy_repository.name

  required_review_thread_resolution = true
  required_approving_review_count   = 0
}

module "cloudflare_workload_identity_deploy_ruleset_required_status_checks" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cloudflare_workload_identity_deploy_repository.name
  name       = "Required status checks"

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

resource "github_repository_environment" "cloudflare_workload_identity_deploy_production" {
  repository  = module.cloudflare_workload_identity_deploy_repository.name
  environment = "production"

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "cloudflare_workload_identity_deploy_production_main" {
  repository     = module.cloudflare_workload_identity_deploy_repository.name
  environment    = github_repository_environment.cloudflare_workload_identity_deploy_production.environment
  branch_pattern = "main"
}
