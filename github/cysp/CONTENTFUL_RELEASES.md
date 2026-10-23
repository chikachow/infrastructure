# Contentful provider release infrastructure

This root manages the release environments and tag rules for
`cysp/terraform-provider-contentful`. Follow the provider's
[release runbook](https://github.com/cysp/terraform-provider-contentful/blob/main/docs/releasing.md)
for the full rollout, App permissions, secrets, and recovery procedure.

- `release-preparation` permits the `main` branch and holds the dedicated release
  App private key. `release` permits `v*` tags and retains the existing signing
  secrets. Neither environment adds another publication approval gate.
- The imported tag ruleset permits the existing maintainer and, when configured,
  the dedicated App to create version tags. A separate ruleset prevents updates
  and deletion without bypasses. Terraform installs that protection before
  narrowing the imported rule.
- Set `terraform_provider_contentful_release_app` after creating and installing
  the App only on the provider repository. The object contains its numeric
  `app_id` and string `client_id`; it contains no private key. Store
  `RELEASE_APP_PRIVATE_KEY` directly in the `release-preparation` environment.
  Leaving the variable null does not grant any App bypass or create its variable.
- Immutable releases are enabled separately after the provider's draft-only
  publisher is merged. The pinned GitHub provider does not manage that setting.
  Preparation refuses to run until it is enabled.

The import IDs identify the existing release environment, its tag policy, and
its combined tag rule. Review the real infrastructure plan before applying;
mocked tests cannot establish current remote state, App installation, or GitHub
permission behavior. Rollback must preserve the signing environment and tag
mutation protection.

Validate locally without initializing the remote state backend:

```sh
terraform -chdir=github/cysp init -backend=false -lockfile=readonly
terraform -chdir=github/cysp validate
terraform -chdir=github/cysp test
```

The mocked tests scope their plans to this release concern and override imported
resources. They check configuration boundaries with and without an App identity;
they never create GitHub resources. TFLint runs in the existing root CI matrix.
