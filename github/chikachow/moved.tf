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

moved {
  from = github_repository.booze
  to   = module.booze_repository.github_repository.this
}

moved {
  from = github_branch_default.booze
  to   = module.booze_repository.github_branch_default.this[0]
}

moved {
  from = github_repository_dependabot_security_updates.booze
  to   = module.booze_repository.github_repository_dependabot_security_updates.this[0]
}

moved {
  from = github_repository_vulnerability_alerts.booze
  to   = module.booze_repository.github_repository_vulnerability_alerts.this[0]
}

moved {
  from = module.cloudflare_workload_identity_issuer_ruleset_protect_default_branch
  to   = module.cloudflare_workload_identity_ruleset_protect_default_branch
}

moved {
  from = module.cloudflare_workload_identity_issuer_ruleset_ci
  to   = module.cloudflare_workload_identity_ruleset_ci
}

moved {
  from = module.cloudflare_workload_identity_issuer_ruleset_require_codeql
  to   = module.cloudflare_workload_identity_ruleset_require_codeql
}

moved {
  from = github_repository_environment.cloudflare_workload_identity_issuer_production
  to   = github_repository_environment.cloudflare_workload_identity_production
}

moved {
  from = github_repository_environment.cloudflare_workload_identity_issuer_deploy_production
  to   = github_repository_environment.cloudflare_workload_identity_deploy_production
}

moved {
  from = module.cloudflare_workload_identity_issuer_repository.github_repository.this
  to   = module.cloudflare_workload_identity_repository.module.repository.github_repository.this
}

moved {
  from = module.cloudflare_workload_identity_repository.module.repository.github_repository.this
  to   = module.cloudflare_workload_identity_repository.github_repository.this
}

moved {
  from = module.cloudflare_workload_identity_issuer_deploy_repository.github_repository.this
  to   = module.cloudflare_workload_identity_deploy_repository.module.repository.github_repository.this
}

moved {
  from = module.cloudflare_workload_identity_deploy_repository.module.repository.github_repository.this
  to   = module.cloudflare_workload_identity_deploy_repository.github_repository.this
}

moved {
  from = module.infrastructure_ruleset_tflint
  to   = module.infrastructure_status_rulesets["tflint"]
}

moved {
  from = module.infrastructure_ruleset_atlantis_apply
  to   = module.infrastructure_status_rulesets["atlantis_apply"]
}
