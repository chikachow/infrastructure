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

  required_status_checks = [
    {
      context        = "fastify-openapi-generated / fastify-openapi-generated"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "drizzle-schema / drizzle-schema"
      integration_id = local.github_actions_integration_id
    },
  ]
}

module "graphql_schema_registry_ruleset_require_passing_tests" {
  source = "../../modules/github-repository-ruleset-required-status-checks"

  repository = module.graphql_schema_registry_repository.name
  name       = "Require passing tests"

  required_status_checks = [
    {
      context        = "test / unit"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "test / integration"
      integration_id = local.github_actions_integration_id
    },
    {
      context        = "neon / pgschema-apply"
      integration_id = local.github_actions_integration_id
    },
  ]
}

resource "github_actions_variable" "graphql_schema_registry_cyspbot_app_id" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "CYSPBOT_APP_ID"
  value         = local.cyspbot_github_app_id
}

resource "github_actions_variable" "graphql_schema_registry_neon_database_name" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "NEON_DATABASE_NAME"
  value         = "graphql_schema_registry"
}

resource "github_actions_variable" "graphql_schema_registry_neon_host" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "NEON_HOST"
  value         = "ep-frosty-heart-a7w2yndv.ap-southeast-2.aws.neon.tech"
}

resource "github_actions_variable" "graphql_schema_registry_neon_parent_branch" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "NEON_PARENT_BRANCH"
  value         = "production"
}

resource "github_actions_variable" "graphql_schema_registry_neon_project_id" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "NEON_PROJECT_ID"
  value         = "quiet-pine-85242794"
}

resource "github_actions_variable" "graphql_schema_registry_neon_role_name" {
  repository    = module.graphql_schema_registry_repository.name
  variable_name = "NEON_ROLE_NAME"
  value         = "graphql_schema_registry_owner"
}
