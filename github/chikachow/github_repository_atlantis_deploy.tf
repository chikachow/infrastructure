module "atlantis_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "atlantis-deploy"
  description = "Fly.io deployment pipeline for chikachow Atlantis"
  visibility  = "private"

  allow_auto_merge = false
  default_branch   = null
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
