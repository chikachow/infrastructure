moved {
  from = github_repository.infrastructure
  to   = module.infrastructure_repository.github_repository.this
}

moved {
  from = github_branch_default.infrastructure
  to   = module.infrastructure_repository.github_branch_default.this[0]
}

moved {
  from = github_repository_dependabot_security_updates.infrastructure
  to   = module.infrastructure_repository.github_repository_dependabot_security_updates.this[0]
}

moved {
  from = github_repository_vulnerability_alerts.infrastructure
  to   = module.infrastructure_repository.github_repository_vulnerability_alerts.this[0]
}

moved {
  from = github_repository_ruleset.infrastructure_protect_default_branch
  to   = module.infrastructure_ruleset_protect_default_branch.github_repository_ruleset.this
}

moved {
  from = github_repository_ruleset.infrastructure_tflint
  to   = module.infrastructure_ruleset_tflint.github_repository_ruleset.this
}

moved {
  from = github_repository_ruleset.infrastructure_atlantis_apply
  to   = module.infrastructure_ruleset_atlantis_apply.github_repository_ruleset.this
}
