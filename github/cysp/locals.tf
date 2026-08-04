locals {
  github_owner = "cysp"

  github_repository_role_maintain_id = 2
  github_repository_role_admin_id    = 5

  github_repository_role_maintain_pull_request_bypass_actor = {
    actor_id    = local.github_repository_role_maintain_id
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
  }
  github_repository_role_maintain_always_bypass_actor = {
    actor_id    = local.github_repository_role_maintain_id
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }
  github_repository_role_admin_pull_request_bypass_actor = {
    actor_id    = local.github_repository_role_admin_id
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
  }
  github_repository_role_admin_always_bypass_actor = {
    actor_id    = local.github_repository_role_admin_id
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  github_actions_integration_id = 15368
  codecov_integration_id        = 254
  cyspbot_github_app_id         = "2419473"

  terraform_github_app_pem_file_provided = nonsensitive(var.cysp_terraform_github_app_pem_file != null)
  terraform_github_app_auth_enabled = (
    local.terraform_github_app_pem_file_provided ||
    var.cysp_terraform_github_app_pem_file_path != null
  )
}
