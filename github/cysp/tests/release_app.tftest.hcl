mock_provider "github" {}

run "release_app_can_only_create_tags" {
  command = plan

  assert {
    condition = (
      github_repository_ruleset.terraform_provider_contentful_release_tags.target == "tag" &&
      github_repository_ruleset.terraform_provider_contentful_release_tags.enforcement == "active" &&
      toset(github_repository_ruleset.terraform_provider_contentful_release_tags.conditions[0].ref_name[0].include) == toset(["refs/tags/v*"])
    )
    error_message = "The creation rule must protect version tags."
  }

  assert {
    condition = (
      github_repository_ruleset.terraform_provider_contentful_release_tags.rules[0].creation == true &&
      github_repository_ruleset.terraform_provider_contentful_release_tags.rules[0].update != true &&
      github_repository_ruleset.terraform_provider_contentful_release_tags.rules[0].deletion != true &&
      toset(github_repository_ruleset.terraform_provider_contentful_release_tags.bypass_actors) == toset([
        { actor_id = 742696, actor_type = "User", bypass_mode = "always" },
        { actor_id = 5575251, actor_type = "Integration", bypass_mode = "always" },
      ])
    )
    error_message = "Only the maintainer and cyspbot-releaser may bypass tag creation."
  }

  assert {
    condition = (
      github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.target == "tag" &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.enforcement == "active" &&
      toset(github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.conditions[0].ref_name[0].include) == toset(["refs/tags/v*"]) &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.rules[0].update == true &&
      github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.rules[0].deletion == true &&
      length(github_repository_ruleset.terraform_provider_contentful_release_tag_immutability.bypass_actors) == 0
    )
    error_message = "Tag updates and deletion must remain forbidden without an App bypass."
  }
}
