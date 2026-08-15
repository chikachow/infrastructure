# These settings are enforced by the organization security configuration, which
# rejects attempts to disable them. Remove only their Terraform state entries;
# deleting the repository removes the underlying settings with it.
removed {
  from = module.github_app_token_broker_action_repository.github_repository_dependabot_security_updates.this

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.github_app_token_broker_action_repository.github_repository_vulnerability_alerts.this

  lifecycle {
    destroy = false
  }
}
