resource "cloudflare_queue" "cyspbot_github_webhook_jobs" {
  account_id = local.account_id
  queue_name = "cyspbot-github-webhook-jobs"

  settings = {
    delivery_delay           = 0
    message_retention_period = 604800
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_queue" "cyspbot_github_webhook_jobs_dlq" {
  account_id = local.account_id
  queue_name = "cyspbot-github-webhook-jobs-dlq"

  settings = {
    delivery_delay           = 0
    message_retention_period = 604800
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_queue_consumer" "cyspbot_github_webhook_processor" {
  account_id        = local.account_id
  queue_id          = cloudflare_queue.cyspbot_github_webhook_jobs.id
  script_name       = "cyspbot-github-webhook-processor"
  type              = "worker"
  dead_letter_queue = cloudflare_queue.cyspbot_github_webhook_jobs_dlq.queue_name

  settings = {
    batch_size       = 1
    max_retries      = 5
    max_wait_time_ms = 5000
    retry_delay      = 60
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_d1_database" "cyspbot" {
  account_id = local.account_id
  name       = "cyspbot"

  read_replication = {
    mode = "disabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_workers_custom_domain" "cyspbot" {
  account_id = local.account_id
  zone_id    = local.chikachow_org_zone_id
  hostname   = "cyspbot.chikachow.org"
  service    = "cyspbot"
}
