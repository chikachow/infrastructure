# Chikachow Infrastructure

Terraform configuration for Chikachow and related accounts.

- GitHub roots: [chikachow](github/chikachow) and [cysp](github/cysp).
- Cloudflare roots: [chikachow account](cloudflare/chikachow/account) and [chikachow.org zone](cloudflare/chikachow/zones/chikachow-org).
- Shared [modules](modules) for GitHub repositories and rulesets.

[atlantis.yaml](atlantis.yaml) registers the Terraform roots for Atlantis.
The [TFLint workflow](.github/workflows/tflint.yml) checks formatting, validates and
lints each root, and runs the mocked GitHub module tests. Its required aggregate
check remains `tflint`.

## GitHub repository policies

Each repository's settings, rulesets, and environments are declared in its
`github_repository_*.tf` file within the relevant GitHub root.

For security settings outside the locked provider, use the
[ownership and drift-check procedure](docs/operations/github-security-ownership.md).

Required status check contexts must match the check names reported by GitHub
Actions. Update the repository's ruleset configuration when renaming a required
check.

If required checks prevent a necessary repair and no bypass actors are configured,
a repository administrator can edit the rulesets. After recovery, restore the
intended rules and reconcile any manual changes with Terraform.

A deployment branch policy allowing `main` with no tag policies permits only
workflow runs on `main`. This policy matches the workflow run's `GITHUB_REF`, not
a commit checked out by a job. Commit selection and validation remain the
responsibility of the deployment workflows.
