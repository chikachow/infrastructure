module "terraform_provider_censusworkspace_repository" {
  source = "../../modules/github-repository"

  name       = "terraform-provider-censusworkspace"
  visibility = "public"

  has_issues = true
}

module "terraform_provider_censusworkspace_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.terraform_provider_censusworkspace_repository.name
}

module "terraform_provider_censusworkspace_status_rulesets" {
  for_each = {
    require_clean_linting = {
      name = "Require clean linting"
      required_status_checks = {
        lint = local.github_actions_integration_id
      }
    }
    require_passing_tests = {
      name = "Require passing tests"
      required_status_checks = {
        test = local.github_actions_integration_id
      }
    }
    require_test_coverage = {
      name = "Require test coverage"
      required_status_checks = {
        "codecov/project" = local.codecov_integration_id
      }
    }
  }

  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.terraform_provider_censusworkspace_repository.name
  name       = each.value.name

  required_status_checks = each.value.required_status_checks
}

module "terraform_provider_censusworkspace_ruleset_require_codeql" {
  source = "../../modules/github-repository-ruleset-require-codeql"

  repository = module.terraform_provider_censusworkspace_repository.name
}

resource "github_actions_variable" "terraform_provider_censusworkspace_cyspbot_app_id" {
  repository    = module.terraform_provider_censusworkspace_repository.name
  variable_name = "CYSPBOT_APP_ID"
  value         = local.cyspbot_github_app_id
}

module "terraform_provider_censusworkspace_ruleset_require_pull_request" {
  source = "../../modules/github-repository-ruleset-require-pull-request"

  repository = module.terraform_provider_censusworkspace_repository.name
}
