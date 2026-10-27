mock_provider "github" {}

run "sole_maintainer_merge_contract" {
  command = plan

  variables {
    repository = "example"
  }

  assert {
    condition = (
      one(one(github_repository_ruleset.this.rules).pull_request).required_approving_review_count == 0 &&
      !one(one(github_repository_ruleset.this.rules).pull_request).require_code_owner_review &&
      !one(one(github_repository_ruleset.this.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.this.rules).pull_request).required_review_thread_resolution
    )
    error_message = "Routine merges must resolve review threads without requiring another human's approval."
  }

  assert {
    condition = (
      github_repository_ruleset.this.enforcement == "active" &&
      length(github_repository_ruleset.this.bypass_actors) == 0 &&
      toset(one(one(github_repository_ruleset.this.conditions).ref_name).include) == toset(["~DEFAULT_BRANCH"])
    )
    error_message = "The default branch must require pull requests without routine bypasses."
  }
}
