mock_provider "github" {}

run "default_ruleset_configuration" {
  command = plan

  variables {
    repository = "example"
    name       = "Required checks"
    required_status_checks = {
      build = 15368
      test  = 15369
    }
  }

  assert {
    condition = {
      for required_check in one(one(github_repository_ruleset.this.rules).required_status_checks).required_check :
      required_check.context => required_check.integration_id
      } == {
      build = 15368
      test  = 15369
    }
    error_message = "The ruleset must require the configured checks with their integration IDs."
  }

  assert {
    condition     = one(one(github_repository_ruleset.this.rules).required_status_checks).do_not_enforce_on_create
    error_message = "Required checks must not be enforced when creating a matching branch by default."
  }

  assert {
    condition     = !one(one(github_repository_ruleset.this.rules).required_status_checks).strict_required_status_checks_policy
    error_message = "Required checks must not require an up-to-date branch by default."
  }

  assert {
    condition     = toset(one(one(github_repository_ruleset.this.conditions).ref_name).include) == toset(["~DEFAULT_BRANCH"])
    error_message = "The ruleset must target the default branch by default."
  }
}
