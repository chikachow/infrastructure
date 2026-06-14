variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Ruleset name."
  type        = string
  default     = "Require Pull Request"
}

variable "enforcement" {
  description = "Ruleset enforcement level."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "disabled", "evaluate"], var.enforcement)
    error_message = "enforcement must be one of: active, disabled, evaluate."
  }
}

variable "allowed_merge_methods" {
  description = "Merge methods allowed by the pull request rule."
  type        = list(string)
  default     = ["merge", "squash", "rebase"]

  validation {
    condition = alltrue([
      for method in var.allowed_merge_methods : contains(["merge", "squash", "rebase"], method)
    ])
    error_message = "allowed_merge_methods entries must be one of: merge, squash, rebase."
  }
}

variable "dismiss_stale_reviews_on_push" {
  description = "Whether new commits dismiss stale pull request approvals."
  type        = bool
  default     = false
}

variable "require_code_owner_review" {
  description = "Whether pull requests require review from code owners."
  type        = bool
  default     = false
}

variable "require_last_push_approval" {
  description = "Whether the most recent pusher must be someone other than the approving reviewer."
  type        = bool
  default     = false
}

variable "required_approving_review_count" {
  description = "Number of approving reviews required before merge."
  type        = number
  default     = 0

  validation {
    condition     = var.required_approving_review_count >= 0
    error_message = "required_approving_review_count must be zero or greater."
  }
}

variable "required_review_thread_resolution" {
  description = "Whether all pull request review threads must be resolved before merge."
  type        = bool
  default     = false
}

variable "bypass_actors" {
  description = "Ruleset bypass actors."
  type = list(object({
    actor_id    = number
    actor_type  = string
    bypass_mode = string
  }))
  default = []
}

variable "ref_include" {
  description = "Ref name include patterns."
  type        = list(string)
  default     = ["~DEFAULT_BRANCH"]
}

variable "ref_exclude" {
  description = "Ref name exclude patterns."
  type        = list(string)
  default     = []
}
