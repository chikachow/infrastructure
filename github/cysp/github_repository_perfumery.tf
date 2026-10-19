module "perfumery_repository" {
  source = "../../modules/github-repository"

  name        = "perfumery"
  description = "Perfumery application"
  visibility  = "private"

  allow_auto_merge = false
}
