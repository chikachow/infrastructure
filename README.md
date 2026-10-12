# Chikachow Infrastructure

Terraform configuration for Chikachow and related accounts.

- GitHub roots: [chikachow](github/chikachow) and [cysp](github/cysp).
- Cloudflare roots: [chikachow account](cloudflare/chikachow/account) and [chikachow.org zone](cloudflare/chikachow/zones/chikachow-org).
- Shared [modules](modules) for GitHub repositories and rulesets.

[atlantis.yaml](atlantis.yaml) registers the Terraform roots for Atlantis.
The [TFLint workflow](.github/workflows/tflint.yml) checks each root.
