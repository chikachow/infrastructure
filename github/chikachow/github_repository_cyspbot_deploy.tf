module "cyspbot_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "cyspbot-deploy"
  description = "Private deployment pipeline for chikachow/cyspbot"
  visibility  = "private"

  allow_auto_merge = false
  allow_forking    = null
  default_branch   = null
}

resource "github_repository_environment" "cyspbot_deploy_production" {
  repository  = module.cyspbot_deploy_repository.name
  environment = "production"
}
