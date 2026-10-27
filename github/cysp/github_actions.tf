locals {
  actions_repositories = {
    booze                              = module.booze_repository.name
    graphql_schema_registry            = module.graphql_schema_registry_repository.name
    perfumery                          = module.perfumery_repository.name
    terraform_provider_braze           = module.terraform_provider_braze_repository.name
    terraform_provider_censusworkspace = module.terraform_provider_censusworkspace_repository.name
    terraform_provider_contentful      = module.terraform_provider_contentful_repository.name
    terraform_provider_typesense       = module.terraform_provider_typesense_repository.name
  }
}

resource "github_actions_repository_permissions" "this" {
  for_each = local.actions_repositories

  repository           = each.value
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}

import {
  for_each = local.actions_repositories
  to       = github_actions_repository_permissions.this[each.key]
  id       = each.value
}
