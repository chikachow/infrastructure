module "cloudflare_workload_identity_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "cloudflare-workload-identity-deploy"
  description = "Private deployment pipeline for chikachow/cloudflare-workload-identity"
  visibility  = "private"

  allow_auto_merge = false
  default_branch   = null

  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

resource "github_repository_environment" "cloudflare_workload_identity_deploy_production" {
  repository  = module.cloudflare_workload_identity_deploy_repository.name
  environment = "production"
}
