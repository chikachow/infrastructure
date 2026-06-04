resource "github_repository_ruleset" "this" {
  repository = var.repository

  name   = var.name
  target = "branch"

  enforcement = var.enforcement

  dynamic "bypass_actors" {
    for_each = var.bypass_actors

    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  conditions {
    ref_name {
      include = var.ref_include
      exclude = var.ref_exclude
    }
  }

  rules {
    required_status_checks {
      strict_required_status_checks_policy = var.strict_required_status_checks_policy

      dynamic "required_check" {
        for_each = var.required_status_checks

        content {
          context        = required_check.value.context
          integration_id = required_check.value.integration_id
        }
      }
    }
  }
}
