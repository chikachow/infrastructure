output "name" {
  description = "Repository name."
  value       = github_repository.this.name
}

output "node_id" {
  description = "Repository node ID."
  value       = github_repository.this.node_id
}

output "html_url" {
  description = "Repository HTML URL."
  value       = github_repository.this.html_url
}

output "lifecycle_state" {
  description = "Repository lifecycle state."
  value       = var.lifecycle_state
}
