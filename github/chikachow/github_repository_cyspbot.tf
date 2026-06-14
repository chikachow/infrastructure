module "cyspbot_repository" {
  source = "../../modules/github-repository"

  name       = "cyspbot"
  visibility = "private"

  allow_auto_merge = false
  allow_forking    = null
}

resource "github_repository_environment" "cyspbot_production" {
  repository  = module.cyspbot_repository.name
  environment = "production"
}
