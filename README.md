# Chikachow Infrastructure

Terraform monorepo for `chikachow` infrastructure and related accounts.

## Roots

| Root | Manages |
| --- | --- |
| `github/chikachow` | GitHub resources for `chikachow`. |
| `github/cysp` | GitHub resources for `cysp`. |

## Repository composition

Keep each repository in one file, composing the core repository module with
focused capability modules. Use keyed `for_each` only when a repository repeats
the same capability; those keys are Terraform state identities, so renaming one
requires a `moved` block. Keep bespoke raw rulesets explicit.
