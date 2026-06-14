import {
  to = module.cyspbot_repository.github_repository.this
  id = "cyspbot"
}

import {
  to = module.cyspbot_repository.github_branch_default.this[0]
  id = "cyspbot"
}

import {
  to = module.cyspbot_repository.github_repository_dependabot_security_updates.this[0]
  id = "cyspbot"
}

import {
  to = module.cyspbot_repository.github_repository_vulnerability_alerts.this[0]
  id = "cyspbot"
}

import {
  to = github_repository_environment.cyspbot_production
  id = "cyspbot:production"
}

import {
  to = module.cyspbot_deploy_repository.github_repository.this
  id = "cyspbot-deploy"
}

import {
  to = module.cyspbot_deploy_repository.github_repository_dependabot_security_updates.this[0]
  id = "cyspbot-deploy"
}

import {
  to = module.cyspbot_deploy_repository.github_repository_vulnerability_alerts.this[0]
  id = "cyspbot-deploy"
}
