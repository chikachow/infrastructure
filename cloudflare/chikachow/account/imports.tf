import {
  to = cloudflare_queue.cyspbot_github_webhook_jobs
  id = "${local.account_id}/6338a52a8dd04e92bd87b617eadbb4e5"
}

import {
  to = cloudflare_queue.cyspbot_github_webhook_jobs_dlq
  id = "${local.account_id}/3a78047c8cf44661a3e9867f5c6bbe08"
}

import {
  to = cloudflare_d1_database.cyspbot
  id = "${local.account_id}/35a687d9-6669-4021-8ce6-07def640e973"
}

import {
  to = cloudflare_workers_custom_domain.cyspbot
  id = "${local.account_id}/2d84bcf1d5357979c9e1d7b3bfc50d9fa603a01f"
}
