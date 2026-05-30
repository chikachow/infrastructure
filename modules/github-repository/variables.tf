variable "name" {
  description = "Repository name."
  type        = string
}

variable "lifecycle_state" {
  description = "Repository lifecycle state. Active repositories receive the full standard configuration, retiring repositories receive only archive-preparation settings, and archived repositories receive only metadata plus archived state."
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
  description = "Default branch to manage while the repository is active."
  type        = string
  default     = "main"
}

variable "has_issues" {
  description = "Whether active repositories have issues enabled."
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Whether active repositories have projects enabled."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Whether active repositories have wiki enabled."
  type        = bool
  default     = false
}

variable "has_discussions" {
  description = "Whether active repositories have discussions enabled."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Whether active repositories allow merge commits."
  type        = bool
  default     = false
}

variable "allow_squash_merge" {
  description = "Whether active repositories allow squash merges."
  type        = bool
  default     = false
}

variable "allow_rebase_merge" {
  description = "Whether active repositories allow rebase merges."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Whether active repositories allow auto-merge."
  type        = bool
  default     = true
}

variable "allow_update_branch" {
  description = "Whether active repositories always allow pull request branches to be updated."
  type        = bool
  default     = true
}

variable "allow_forking" {
  description = "Whether active repositories allow forking."
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "Whether active repositories delete head branches after merge."
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

variable "secret_scanning_enabled" {
  description = "Whether active and retiring repositories have secret scanning enabled."
  type        = bool
  default     = true
}

variable "secret_scanning_push_protection_enabled" {
  description = "Whether active and retiring repositories have secret scanning push protection enabled."
  type        = bool
  default     = true
}

variable "dependabot_security_updates_enabled" {
  description = "Whether active and retiring repositories have Dependabot security updates enabled."
  type        = bool
  default     = true
}

variable "vulnerability_alerts_enabled" {
  description = "Whether active and retiring repositories have vulnerability alerts enabled."
  type        = bool
  default     = true
}
