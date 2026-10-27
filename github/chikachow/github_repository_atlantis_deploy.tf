module "atlantis_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "atlantis-deploy"
  description = "Fly.io deployment pipeline for chikachow Atlantis"
  visibility  = "private"
}

module "atlantis_deploy_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.atlantis_deploy_repository.name
}

module "atlantis_deploy_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.atlantis_deploy_repository.name

  required_review_thread_resolution = true
  required_approving_review_count   = 0
}

module "atlantis_deploy_ruleset_required_status_checks" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.atlantis_deploy_repository.name
  name       = "Required status checks"

  required_status_checks = {
    "validate-atlantis-repo-config / validate" = local.github_actions_integration_id
    "validate-fly-config / validate"           = local.github_actions_integration_id
  }
}

resource "github_repository_environment" "atlantis_deploy_production" {
  repository        = module.atlantis_deploy_repository.name
  environment       = "production"
  can_admins_bypass = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "atlantis_deploy_production_main" {
  repository     = module.atlantis_deploy_repository.name
  environment    = github_repository_environment.atlantis_deploy_production.environment
  branch_pattern = "main"
}
