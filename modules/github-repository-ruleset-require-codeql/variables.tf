variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Ruleset name."
  type        = string
  default     = "Require CodeQL"
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

variable "alerts_threshold" {
  description = "CodeQL alerts threshold."
  type        = string
  default     = "errors"

  validation {
    condition     = contains(["none", "errors", "errors_and_warnings", "all"], var.alerts_threshold)
    error_message = "alerts_threshold must be one of: none, errors, errors_and_warnings, all."
  }
}

variable "security_alerts_threshold" {
  description = "CodeQL security alerts threshold."
  type        = string
  default     = "high_or_higher"

  validation {
    condition = contains([
      "none",
      "critical",
      "high_or_higher",
      "medium_or_higher",
      "all",
    ], var.security_alerts_threshold)
    error_message = "security_alerts_threshold must be one of: none, critical, high_or_higher, medium_or_higher, all."
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
