module "cloudflare_workload_identity_issuer_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "cloudflare-workload-identity-issuer-deploy"
  description = "Private deployment pipeline for chikachow/cloudflare-workload-identity-issuer"
  visibility  = "private"

  allow_auto_merge = false
  default_branch   = null
}

resource "github_repository_environment" "cloudflare_workload_identity_issuer_deploy_production" {
  repository  = module.cloudflare_workload_identity_issuer_deploy_repository.name
  environment = "production"
}
