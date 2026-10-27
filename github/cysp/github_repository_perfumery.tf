module "perfumery_repository" {
  source = "../../modules/github-repository"

  name        = "perfumery"
  description = "Perfumery application"
  visibility  = "private"

  allow_auto_merge = false
}

resource "github_actions_repository_permissions" "perfumery" {
  repository           = module.perfumery_repository.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}
