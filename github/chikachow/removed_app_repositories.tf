# Detach before transferring these repositories to cysp.
# Their resources will be imported into github/cysp after the GitHub transfer.

removed {
  from = module.booze_repository

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.booze_ruleset_protect_default_branch

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.booze_ruleset_ci

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.perfumery_repository

  lifecycle {
    destroy = false
  }
}
