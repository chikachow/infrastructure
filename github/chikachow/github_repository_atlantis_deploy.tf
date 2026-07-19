module "atlantis_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "atlantis-deploy"
  description = "Fly.io deployment pipeline for chikachow Atlantis"
  visibility  = "private"

  allow_auto_merge = true
  default_branch   = null
}

resource "github_repository_environment" "atlantis_deploy_production" {
  repository  = module.atlantis_deploy_repository.name
  environment = "production"
}
