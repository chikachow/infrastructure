resource "github_repository_ruleset" "creation" {
  repository = var.repository

  name   = var.name
  target = "tag"

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
    creation = true
  }

  # Establish mutation protection before granting creation bypass.
  depends_on = [github_repository_ruleset.immutability]
}

resource "github_repository_ruleset" "immutability" {
  repository = var.repository

  name   = var.immutability_name
  target = "tag"

  enforcement = var.enforcement

  conditions {
    ref_name {
      include = var.ref_include
      exclude = var.ref_exclude
    }
  }

  rules {
    update   = true
    deletion = true
  }
}
