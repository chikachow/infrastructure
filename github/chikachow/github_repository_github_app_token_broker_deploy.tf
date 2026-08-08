module "github_app_token_broker_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "github-app-token-broker-deploy"
  description = "Private deployment pipeline for chikachow/github-app-token-broker"
  visibility  = "private"

  allow_auto_merge = false
  default_branch   = null

  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

resource "github_repository_environment" "github_app_token_broker_deploy_production" {
  repository  = module.github_app_token_broker_deploy_repository.name
  environment = "production"
}
