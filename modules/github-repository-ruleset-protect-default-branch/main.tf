resource "github_repository_ruleset" "this" {
  repository = var.repository

  name   = var.name
  target = "branch"

  enforcement = var.enforcement

  conditions {
    ref_name {
      include = var.ref_include
      exclude = var.ref_exclude
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
  }
}
