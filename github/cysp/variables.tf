variable "cysp_terraform_github_app_id" {
  description = "GitHub App ID for the cysp-terraform GitHub App."
  type        = string
  default     = "3855267"
}

variable "cysp_terraform_github_app_installation_id" {
  description = "GitHub App installation ID for the cysp-terraform GitHub App installed in the cysp account."
  type        = string
  default     = "135478241"
}

variable "cysp_terraform_github_app_pem_file" {
  description = "PEM-encoded private key content for the Terraform GitHub App. When unset, the GitHub provider uses ambient credentials."
  type        = string
  default     = null
  sensitive   = true
}

variable "cysp_terraform_github_app_pem_file_path" {
  description = "Local filesystem path to the Terraform GitHub App private key. Used when cysp_terraform_github_app_pem_file is not set. When unset, the GitHub provider uses ambient credentials."
  type        = string
  default     = null

  validation {
    condition     = var.cysp_terraform_github_app_pem_file == null || var.cysp_terraform_github_app_pem_file_path == null
    error_message = "Set at most one of cysp_terraform_github_app_pem_file or cysp_terraform_github_app_pem_file_path."
  }
}
