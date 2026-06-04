locals {
  github_owner = "chikachow"

  github_actions_integration_id = 15368
  atlantis_integration_id       = 3852202

  terraform_github_app_pem_file_provided = nonsensitive(var.chikachow_terraform_github_app_pem_file != null)
  terraform_github_app_auth_enabled = (
    local.terraform_github_app_pem_file_provided ||
    var.chikachow_terraform_github_app_pem_file_path != null
  )
}
