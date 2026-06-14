variable "name" {
  description = "Repository name."
  type        = string
}

variable "lifecycle_state" {
  description = "Repository lifecycle state. Active and retiring repositories keep the same configured repository settings; archived repositories keep those settings and set archived."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "retiring", "archived"], var.lifecycle_state)
    error_message = "lifecycle_state must be one of: active, retiring, archived."
  }
}

variable "visibility" {
  description = "Repository visibility."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public", "internal"], var.visibility)
    error_message = "visibility must be one of: private, public, internal."
  }
}

variable "description" {
  description = "Repository description."
  type        = string
  default     = null
}

variable "homepage_url" {
  description = "Repository homepage URL."
  type        = string
  default     = null
}

variable "topics" {
  description = "Repository topics."
  type        = list(string)
  default     = []
}

variable "default_branch" {
  description = "Default branch to manage. Set to null for newly-created empty repositories until their first branch has been pushed."
  type        = string
  default     = "main"
}

variable "has_issues" {
  description = "Whether repositories have issues enabled."
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Whether repositories have projects enabled."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Whether repositories have wiki enabled."
  type        = bool
  default     = false
}

variable "has_discussions" {
  description = "Whether repositories have discussions enabled."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Whether repositories allow merge commits."
  type        = bool
  default     = false

  validation {
    condition     = var.allow_merge_commit || var.allow_squash_merge || var.allow_rebase_merge
    error_message = "At least one merge method must be enabled."
  }
}

variable "allow_squash_merge" {
  description = "Whether repositories allow squash merges."
  type        = bool
  default     = false
}

variable "allow_rebase_merge" {
  description = "Whether repositories allow rebase merges."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Whether repositories allow auto-merge."
  type        = bool
  default     = true
}

variable "allow_update_branch" {
  description = "Whether repositories always allow pull request branches to be updated."
  type        = bool
  default     = true
}

variable "allow_forking" {
  description = "Whether repositories allow forking."
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "Whether repositories delete head branches after merge."
  type        = bool
  default     = true
}

variable "merge_commit_message" {
  description = "Default message for merge commits."
  type        = string
  default     = "PR_TITLE"
}

variable "merge_commit_title" {
  description = "Default title for merge commits."
  type        = string
  default     = "MERGE_MESSAGE"
}

variable "squash_merge_commit_message" {
  description = "Default message for squash merge commits."
  type        = string
  default     = "COMMIT_MESSAGES"
}

variable "squash_merge_commit_title" {
  description = "Default title for squash merge commits."
  type        = string
  default     = "COMMIT_OR_PR_TITLE"
}

variable "security_and_analysis" {
  description = "Repository security_and_analysis settings. Public repositories default code security, secret scanning, and push protection to enabled. Private and internal repositories leave those settings unmanaged unless advanced_security or the specific setting is explicitly configured."
  type = object({
    advanced_security                     = optional(bool)
    code_security                         = optional(bool)
    secret_scanning                       = optional(bool)
    secret_scanning_ai_detection          = optional(bool)
    secret_scanning_non_provider_patterns = optional(bool)
    secret_scanning_push_protection       = optional(bool)
  })
  default  = {}
  nullable = false

  validation {
    condition = !(
      var.security_and_analysis.secret_scanning == false &&
      var.security_and_analysis.secret_scanning_push_protection == true
    )
    error_message = "security_and_analysis.secret_scanning_push_protection cannot be true when security_and_analysis.secret_scanning is false."
  }
}

variable "dependabot_security_updates_enabled" {
  description = "Whether repositories have Dependabot security updates enabled."
  type        = bool
  default     = true
}

variable "vulnerability_alerts_enabled" {
  description = "Whether repositories have vulnerability alerts enabled."
  type        = bool
  default     = true
}
