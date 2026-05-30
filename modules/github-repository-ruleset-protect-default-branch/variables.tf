variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Ruleset name."
  type        = string
  default     = "protect default branch"
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
