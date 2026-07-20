provider "github" {
  owner         = local.github_owner
  legacy_client = false

  dynamic "app_auth" {
    for_each = local.terraform_github_app_auth_enabled ? [true] : []

    content {
      id              = var.cysp_terraform_github_app_id
      installation_id = var.cysp_terraform_github_app_installation_id
      pem_file = (
        local.terraform_github_app_pem_file_provided
        ? var.cysp_terraform_github_app_pem_file
        : sensitive(file(var.cysp_terraform_github_app_pem_file_path))
      )
    }
  }
}
