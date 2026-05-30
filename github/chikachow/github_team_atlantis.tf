resource "github_team" "atlantis" {
  name        = "atlantis"
  description = "Members allowed to run Atlantis apply and import commands."
  privacy     = "closed"
}

resource "github_team_membership" "atlantis_cysp" {
  team_id  = github_team.atlantis.id
  username = "cysp"
  role     = "maintainer"
}
