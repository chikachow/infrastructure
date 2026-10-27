module "infrastructure_repository" {
  source = "../../modules/github-repository"

  name       = "infrastructure"
  visibility = "public"

  manage_security_and_analysis        = false
  dependabot_security_updates_enabled = null
  vulnerability_alerts_enabled        = null
}

module "infrastructure_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.infrastructure_repository.name
}

module "infrastructure_status_rulesets" {
  for_each = {
    tflint = {
      name = "tflint"
      required_status_checks = {
        tflint = local.github_actions_integration_id
      }
    }
    atlantis_apply = {
      name = "atlantis/apply"
      required_status_checks = {
        "atlantis/apply" = local.atlantis_integration_id
      }
    }
  }

  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.infrastructure_repository.name
  name       = each.value.name

  bypass_actors          = try(each.value.bypass_actors, [])
  required_status_checks = each.value.required_status_checks
}

module "infrastructure_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.infrastructure_repository.name
}

module "infrastructure_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.infrastructure_repository.name
}
