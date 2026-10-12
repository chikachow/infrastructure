resource "cloudflare_workers_route" "cyspbot_github_webhooks" {
  zone_id = local.zone_id
  pattern = "cyspbot.chikachow.org/github/webhooks*"
  script  = "cyspbot-github-webhook-receiver"
}

resource "cloudflare_workers_route" "cyspbot_token" {
  zone_id = local.zone_id
  pattern = "cyspbot.chikachow.org/token*"
  script  = "github-app-token-broker"
}
