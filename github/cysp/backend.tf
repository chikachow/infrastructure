terraform {
  backend "s3" {
    bucket = "chikachow-tfstate"
    key    = "github/cysp/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://t3.storage.dev"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_lockfile                = true
    use_path_style              = true
  }
}
