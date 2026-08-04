moved {
  from = github_actions_variable.graphql_schema_registry_cyspbot_app_id
  to   = github_actions_variable.graphql_schema_registry["CYSPBOT_APP_ID"]
}

moved {
  from = github_actions_variable.graphql_schema_registry_neon_database_name
  to   = github_actions_variable.graphql_schema_registry["NEON_DATABASE_NAME"]
}

moved {
  from = github_actions_variable.graphql_schema_registry_neon_host
  to   = github_actions_variable.graphql_schema_registry["NEON_HOST"]
}

moved {
  from = github_actions_variable.graphql_schema_registry_neon_parent_branch
  to   = github_actions_variable.graphql_schema_registry["NEON_PARENT_BRANCH"]
}

moved {
  from = github_actions_variable.graphql_schema_registry_neon_project_id
  to   = github_actions_variable.graphql_schema_registry["NEON_PROJECT_ID"]
}

moved {
  from = github_actions_variable.graphql_schema_registry_neon_role_name
  to   = github_actions_variable.graphql_schema_registry["NEON_ROLE_NAME"]
}

moved {
  from = github_actions_variable.terraform_provider_contentful_contentful_environment_id
  to   = github_actions_variable.terraform_provider_contentful["CONTENTFUL_ENVIRONMENT_ID"]
}

moved {
  from = github_actions_variable.terraform_provider_contentful_contentful_organization_id
  to   = github_actions_variable.terraform_provider_contentful["CONTENTFUL_ORGANIZATION_ID"]
}

moved {
  from = github_actions_variable.terraform_provider_contentful_contentful_space_id
  to   = github_actions_variable.terraform_provider_contentful["CONTENTFUL_SPACE_ID"]
}

moved {
  from = github_actions_variable.terraform_provider_contentful_cyspbot_app_id
  to   = github_actions_variable.terraform_provider_contentful["CYSPBOT_APP_ID"]
}

moved {
  from = module.graphql_schema_registry_ruleset_require_generated_code
  to   = module.graphql_schema_registry_status_rulesets["require_generated_code"]
}

moved {
  from = module.graphql_schema_registry_ruleset_require_passing_tests
  to   = module.graphql_schema_registry_status_rulesets["require_passing_tests"]
}

moved {
  from = module.terraform_provider_censusworkspace_ruleset_require_clean_linting
  to   = module.terraform_provider_censusworkspace_status_rulesets["require_clean_linting"]
}

moved {
  from = module.terraform_provider_censusworkspace_ruleset_require_passing_tests
  to   = module.terraform_provider_censusworkspace_status_rulesets["require_passing_tests"]
}

moved {
  from = module.terraform_provider_censusworkspace_ruleset_require_test_coverage
  to   = module.terraform_provider_censusworkspace_status_rulesets["require_test_coverage"]
}

moved {
  from = module.terraform_provider_contentful_ruleset_require_lint
  to   = module.terraform_provider_contentful_status_rulesets["require_lint"]
}

moved {
  from = module.terraform_provider_contentful_ruleset_require_passing_tests
  to   = module.terraform_provider_contentful_status_rulesets["require_passing_tests"]
}

moved {
  from = module.terraform_provider_contentful_ruleset_require_test_coverage
  to   = module.terraform_provider_contentful_status_rulesets["require_test_coverage"]
}
