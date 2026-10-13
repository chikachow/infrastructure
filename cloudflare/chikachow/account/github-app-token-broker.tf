resource "cloudflare_workers_custom_domain" "github_app_token_broker" {
  account_id = local.account_id
  zone_id    = local.chikachow_org_zone_id
  hostname   = "github-app-token-broker.chikachow.org"
  service    = "github-app-token-broker"
}
