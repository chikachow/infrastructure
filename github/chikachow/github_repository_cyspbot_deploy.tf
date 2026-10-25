module "cyspbot_deploy_repository" {
  source = "../../modules/github-repository"

  name        = "cyspbot-deploy"
  description = "Private deployment pipeline for chikachow/cyspbot"
  visibility  = "private"

  allow_auto_merge = false
}

module "cyspbot_deploy_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.cyspbot_deploy_repository.name
}

module "cyspbot_deploy_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.cyspbot_deploy_repository.name

  required_review_thread_resolution = true
  required_approving_review_count   = 0
}

module "cyspbot_deploy_ruleset_required_status_checks" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.cyspbot_deploy_repository.name
  name       = "Required status checks"

  required_status_checks = {
    ci = local.github_actions_integration_id
  }
}

resource "github_repository_environment" "cyspbot_deploy_production" {
  repository  = module.cyspbot_deploy_repository.name
  environment = "production"
}
