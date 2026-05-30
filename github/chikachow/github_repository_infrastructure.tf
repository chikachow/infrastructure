module "infrastructure_repository" {
  source = "../../modules/github-repository"

  name       = "infrastructure"
  visibility = "public"
}

module "infrastructure_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.infrastructure_repository.name
}

module "infrastructure_ruleset_tflint" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.infrastructure_repository.name
  name       = "tflint"

  required_status_checks = {
    tflint = {
      context        = "tflint"
      integration_id = 15368
    }
  }
}

module "infrastructure_ruleset_atlantis_apply" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.infrastructure_repository.name
  name       = "atlantis/apply"

  required_status_checks = {
    atlantis_apply = {
      context        = "atlantis/apply"
      integration_id = 3852202
    }
  }
}
