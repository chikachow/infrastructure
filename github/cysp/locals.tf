locals {
  github_owner = "cysp"

  terraform_github_app_pem_file_provided = nonsensitive(var.cysp_terraform_github_app_pem_file != null)
  terraform_github_app_auth_enabled = (
    local.terraform_github_app_pem_file_provided ||
    var.cysp_terraform_github_app_pem_file_path != null
  )
}
