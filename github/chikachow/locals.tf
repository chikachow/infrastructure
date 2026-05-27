locals {
  github_owner = "chikachow"

  atlantis_github_app_slug = "chikachow-atlantis"

  terraform_github_app_pem_file_provided = nonsensitive(var.chikachow_terraform_github_app_pem_file != null)
  terraform_github_app_auth_enabled = (
    local.terraform_github_app_pem_file_provided ||
    var.chikachow_terraform_github_app_pem_file_path != null
  )
}
