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
    pull_request {
      allowed_merge_methods             = var.allowed_merge_methods
      dismiss_stale_reviews_on_push     = var.dismiss_stale_reviews_on_push
      require_code_owner_review         = var.require_code_owner_review
      require_last_push_approval        = var.require_last_push_approval
      required_approving_review_count   = var.required_approving_review_count
      required_review_thread_resolution = var.required_review_thread_resolution
    }
  }
}
