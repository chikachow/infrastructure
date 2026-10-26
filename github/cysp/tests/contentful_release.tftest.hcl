mock_provider "github" {}

override_resource {
  target = module.terraform_provider_contentful_repository.github_repository.this
}

override_resource {
  target = module.terraform_provider_contentful_repository.github_branch_default.this[0]
}

override_resource {
  target = module.terraform_provider_contentful_repository.github_repository_dependabot_security_updates.this[0]
}

override_resource {
  target = module.terraform_provider_contentful_repository.github_repository_vulnerability_alerts.this[0]
}

override_resource {
  target = github_repository_environment.terraform_provider_contentful_release["release"]
}

override_resource {
  target = github_repository_environment_deployment_policy.terraform_provider_contentful_release
}

override_resource {
  target = github_repository_ruleset.terraform_provider_contentful_release_tag_creation
}

run "release_boundaries_without_app" {
  command = plan

  plan_options {
    target = [
      github_repository_environment.terraform_provider_contentful_release,
      github_repository_environment_deployment_policy.terraform_provider_contentful_release,
      github_repository_environment_deployment_policy.terraform_provider_contentful_release_preparation,
      github_actions_environment_variable.terraform_provider_contentful_release_app_client_id,
      github_repository_ruleset.terraform_provider_contentful_release_tag_creation,
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation,
    ]
  }

  assert {
    condition = (
      github_repository_environment_deployment_policy.terraform_provider_contentful_release.tag_pattern == "v*" &&
      github_repository_environment_deployment_policy.terraform_provider_contentful_release.branch_pattern == null &&
      github_repository_environment_deployment_policy.terraform_provider_contentful_release_preparation.branch_pattern == "main" &&
      github_repository_environment_deployment_policy.terraform_provider_contentful_release_preparation.tag_pattern == null
    )
    error_message = "Signing must be tag-only and App preparation must be main-only."
  }

  assert {
    condition = alltrue([
      for environment in github_repository_environment.terraform_provider_contentful_release :
      !environment.can_admins_bypass &&
      !environment.deployment_branch_policy[0].protected_branches &&
      environment.deployment_branch_policy[0].custom_branch_policies
    ])
    error_message = "Both environments must enforce their explicit ref policies."
  }

  assert {
    condition = (
      length(github_actions_environment_variable.terraform_provider_contentful_release_app_client_id) == 0 &&
      length(github_repository_ruleset.terraform_provider_contentful_release_tag_creation.bypass_actors) == 1 &&
      one(github_repository_ruleset.terraform_provider_contentful_release_tag_creation.bypass_actors).actor_type == "User" &&
      one(github_repository_ruleset.terraform_provider_contentful_release_tag_creation.bypass_actors).actor_id == 742696
    )
    error_message = "Without an App identity, preserve only the existing maintainer creation bypass."
  }
}

run "app_can_create_but_never_mutate_release_tags" {
  command = plan

  plan_options {
    target = [
      github_repository_environment.terraform_provider_contentful_release,
      github_repository_environment_deployment_policy.terraform_provider_contentful_release,
      github_repository_environment_deployment_policy.terraform_provider_contentful_release_preparation,
      github_actions_environment_variable.terraform_provider_contentful_release_app_client_id,
      github_repository_ruleset.terraform_provider_contentful_release_tag_creation,
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation,
    ]
  }

  variables {
    terraform_provider_contentful_release_app = {
      app_id    = 123456
      client_id = "Iv1.fixture"
    }
  }

  assert {
    condition = (
      github_actions_environment_variable.terraform_provider_contentful_release_app_client_id[0].value == "Iv1.fixture" &&
      github_actions_environment_variable.terraform_provider_contentful_release_app_client_id[0].environment == "release-preparation" &&
      length(github_repository_ruleset.terraform_provider_contentful_release_tag_creation.bypass_actors) == 2 &&
      length([for actor in github_repository_ruleset.terraform_provider_contentful_release_tag_creation.bypass_actors : actor
        if actor.actor_type == "Integration" && actor.actor_id == 123456 && actor.bypass_mode == "always"
      ]) == 1 &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_creation.rules[0].creation &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_creation.rules[0].update != true &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_creation.rules[0].deletion != true
    )
    error_message = "The App must receive its own client ID and only the creation bypass."
  }

  assert {
    condition = (
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.enforcement == "active" &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.target == "tag" &&
      tolist(github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.conditions[0].ref_name[0].include) == tolist(["refs/tags/v*"]) &&
      length(github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.conditions[0].ref_name[0].exclude) == 0 &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.rules[0].update &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.rules[0].deletion &&
      length(github_repository_ruleset.terraform_provider_contentful_release_tag_mutation.bypass_actors) == 0
    )
    error_message = "All release tags must reject updates and deletion without any actor bypass."
  }
}
