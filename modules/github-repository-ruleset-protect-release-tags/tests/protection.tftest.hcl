mock_provider "github" {}

variables {
  repository = "example"
}

run "default_release_tag_protection" {
  command = plan

  assert {
    condition = (
      github_repository_ruleset.creation.name == "Protect release tags" &&
      github_repository_ruleset.immutability.name == "Prevent release tag updates and deletion" &&
      length(github_repository_ruleset.creation.bypass_actors) == 0 &&
      length(github_repository_ruleset.immutability.bypass_actors) == 0 &&
      github_repository_ruleset.creation.rules[0].creation == true &&
      github_repository_ruleset.immutability.rules[0].update == true &&
      github_repository_ruleset.immutability.rules[0].deletion == true
    )
    error_message = "Default release tag protection must forbid creation, updates, and deletion without bypass."
  }
}

run "creation_bypass_does_not_allow_tag_mutation" {
  command = plan

  variables {
    bypass_actors = [
      { actor_id = 101, actor_type = "User", bypass_mode = "always" },
      { actor_id = 202, actor_type = "Integration", bypass_mode = "always" },
    ]
  }

  assert {
    condition = (
      github_repository_ruleset.creation.target == "tag" &&
      github_repository_ruleset.creation.enforcement == "active" &&
      toset(github_repository_ruleset.creation.conditions[0].ref_name[0].include) == toset(["refs/tags/v*"])
    )
    error_message = "The creation rule must protect version tags."
  }

  assert {
    condition = (
      github_repository_ruleset.creation.rules[0].creation == true &&
      github_repository_ruleset.creation.rules[0].update != true &&
      github_repository_ruleset.creation.rules[0].deletion != true &&
      toset(github_repository_ruleset.creation.bypass_actors) == toset([
        { actor_id = 101, actor_type = "User", bypass_mode = "always" },
        { actor_id = 202, actor_type = "Integration", bypass_mode = "always" },
      ])
    )
    error_message = "Only the configured actors may bypass tag creation."
  }

  assert {
    condition = (
      github_repository_ruleset.immutability.target == "tag" &&
      github_repository_ruleset.immutability.enforcement == "active" &&
      toset(github_repository_ruleset.immutability.conditions[0].ref_name[0].include) == toset(["refs/tags/v*"]) &&
      github_repository_ruleset.immutability.rules[0].update == true &&
      github_repository_ruleset.immutability.rules[0].deletion == true &&
      length(github_repository_ruleset.immutability.bypass_actors) == 0
    )
    error_message = "Tag updates and deletion must remain forbidden without an App bypass."
  }
}

run "both_rulesets_share_configured_scope" {
  command = plan

  variables {
    repository        = "custom-repository"
    name              = "Create release tags"
    immutability_name = "Keep release tags"
    ref_include       = ["refs/tags/release/*"]
    ref_exclude       = ["refs/tags/release/test-*"]
    enforcement       = "disabled"
  }

  assert {
    condition = alltrue([
      for ruleset in [github_repository_ruleset.creation, github_repository_ruleset.immutability] :
      ruleset.repository == "custom-repository" &&
      ruleset.target == "tag" &&
      ruleset.enforcement == "disabled" &&
      toset(ruleset.conditions[0].ref_name[0].include) == toset(["refs/tags/release/*"]) &&
      toset(ruleset.conditions[0].ref_name[0].exclude) == toset(["refs/tags/release/test-*"])
    ])
    error_message = "Creation and mutation protection must always use the same repository, tag patterns, and enforcement."
  }

  assert {
    condition = (
      github_repository_ruleset.creation.name == "Create release tags" &&
      github_repository_ruleset.immutability.name == "Keep release tags"
    )
    error_message = "The rulesets must use their configured names."
  }
}
