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
    required_code_scanning {
      required_code_scanning_tool {
        tool                      = "CodeQL"
        alerts_threshold          = var.alerts_threshold
        security_alerts_threshold = var.security_alerts_threshold
      }
    }
  }
}
