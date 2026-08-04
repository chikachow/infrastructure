module "graphql_schema_registry_repository" {
  source = "../../modules/github-repository"

  name       = "graphql-schema-registry"
  visibility = "public"
}

module "graphql_schema_registry_ruleset_protect_default_branch" {
  source = "../../modules/github-repository-ruleset-protect-default-branch"

  repository = module.graphql_schema_registry_repository.name

  bypass_actors = [
    {
      actor_id    = local.github_repository_role_admin_id
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    },
  ]
}

resource "github_repository_ruleset" "graphql_schema_registry_require_pull_request" {
  repository = module.graphql_schema_registry_repository.name

  name   = "Require Pull Request"
  target = "branch"

  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    pull_request {
      allowed_merge_methods             = ["rebase", "merge", "squash"]
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = true
      require_last_push_approval        = false
      required_approving_review_count   = 0
      required_review_thread_resolution = false
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      required_check {
        context        = "lint / lint"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "format / format"
        integration_id = local.github_actions_integration_id
      }

      required_check {
        context        = "typecheck / typecheck"
        integration_id = local.github_actions_integration_id
      }
    }
  }
}

module "graphql_schema_registry_ruleset_require_generated_code" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.graphql_schema_registry_repository.name
  name       = "Require generated code"

  required_status_checks = {
    "fastify-openapi-generated / fastify-openapi-generated" = local.github_actions_integration_id
    "drizzle-schema / drizzle-schema"                       = local.github_actions_integration_id
  }
}

module "graphql_schema_registry_ruleset_require_passing_tests" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.graphql_schema_registry_repository.name
  name       = "Require passing tests"

  required_status_checks = {
    "test / unit"           = local.github_actions_integration_id
    "test / integration"    = local.github_actions_integration_id
    "neon / pgschema-apply" = local.github_actions_integration_id
  }
}

resource "github_actions_variable" "graphql_schema_registry" {
  for_each = {
    CYSPBOT_APP_ID     = local.cyspbot_github_app_id
    NEON_DATABASE_NAME = "graphql_schema_registry"
    NEON_HOST          = "ep-frosty-heart-a7w2yndv.ap-southeast-2.aws.neon.tech"
    NEON_PARENT_BRANCH = "production"
    NEON_PROJECT_ID    = "quiet-pine-85242794"
    NEON_ROLE_NAME     = "graphql_schema_registry_owner"
  }

  repository    = module.graphql_schema_registry_repository.name
  variable_name = each.key
  value         = each.value
}
