moved {
  from = github_repository_ruleset.terraform_provider_contentful_release_tags
  to   = module.terraform_provider_contentful_ruleset_protect_release_tags.github_repository_ruleset.creation
}

moved {
  from = github_repository_ruleset.terraform_provider_contentful_release_tag_immutability
  to   = module.terraform_provider_contentful_ruleset_protect_release_tags.github_repository_ruleset.immutability
}

moved {
  from = module.terraform_provider_contentful_status_rulesets["require_passing_tests"]
  to   = module.terraform_provider_contentful_status_rulesets["require_ci"]
}
