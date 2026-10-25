# Chikachow Infrastructure

Terraform configuration for Chikachow and related accounts.

- GitHub roots: [chikachow](github/chikachow) and [cysp](github/cysp).
- Cloudflare roots: [chikachow account](cloudflare/chikachow/account) and [chikachow.org zone](cloudflare/chikachow/zones/chikachow-org).
- Shared [modules](modules) for GitHub repositories and rulesets.

[atlantis.yaml](atlantis.yaml) registers the Terraform roots for Atlantis.
The [TFLint workflow](.github/workflows/tflint.yml) checks each root.

## GitHub repository policies

Each repository's settings, rulesets, and environments are declared in its
`github_repository_*.tf` file within the relevant GitHub root.

Required status check contexts must match the check names reported by GitHub
Actions. Update the repository's ruleset configuration when renaming a required
check.

If required checks prevent a necessary repair and no bypass actors are configured,
a repository administrator can edit the rulesets. After recovery, restore the
intended rules and reconcile any manual changes with Terraform.
