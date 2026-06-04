variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Ruleset name."
  type        = string
  default     = "Protect default branch"
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
