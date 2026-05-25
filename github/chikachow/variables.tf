variable "chikachow_terraform_github_app_id" {
  description = "GitHub App ID for the chikachow-terraform GitHub App."
  type        = string
  default     = "3854718"
}

variable "chikachow_terraform_github_app_installation_id" {
  description = "GitHub App installation ID for the chikachow-terraform GitHub App installed in the chikachow organization."
  type        = string
  default     = "135466602"
}

variable "chikachow_terraform_github_app_pem_file" {
  description = "PEM-encoded private key content for the Terraform GitHub App. When unset, the GitHub provider uses ambient credentials."
  type        = string
  default     = null
  sensitive   = true
}

variable "chikachow_terraform_github_app_pem_file_path" {
  description = "Local filesystem path to the Terraform GitHub App private key. Used when chikachow_terraform_github_app_pem_file is not set. When unset, the GitHub provider uses ambient credentials."
  type        = string
  default     = null

  validation {
    condition     = var.chikachow_terraform_github_app_pem_file == null || var.chikachow_terraform_github_app_pem_file_path == null
    error_message = "Set at most one of chikachow_terraform_github_app_pem_file or chikachow_terraform_github_app_pem_file_path."
  }
}
