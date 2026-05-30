variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Ruleset name."
  type        = string
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

variable "required_status_checks" {
  description = "Required status checks keyed by stable identifier."
  type = map(object({
    context        = string
    integration_id = number
  }))
}

variable "strict_required_status_checks_policy" {
  description = "Whether the branch must be up to date before merging."
  type        = bool
  default     = false
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
