variable "repository" {
  description = "Repository name."
  type        = string
}

variable "name" {
  description = "Tag creation ruleset name."
  type        = string
  default     = "Protect release tags"
}

variable "immutability_name" {
  description = "Tag update and deletion ruleset name."
  type        = string
  default     = "Prevent release tag updates and deletion"
}

variable "enforcement" {
  description = "Enforcement level for both release tag rulesets."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "disabled", "evaluate"], var.enforcement)
    error_message = "enforcement must be one of: active, disabled, evaluate."
  }
}

variable "bypass_actors" {
  description = "Actors permitted to create matching tags. These actors cannot bypass tag update or deletion protection."
  type = list(object({
    actor_id    = number
    actor_type  = string
    bypass_mode = string
  }))
  default = []
}

variable "ref_include" {
  description = "Ref name include patterns shared by both rulesets."
  type        = list(string)
  default     = ["refs/tags/v*"]
}

variable "ref_exclude" {
  description = "Ref name exclude patterns shared by both rulesets."
  type        = list(string)
  default     = []
}
