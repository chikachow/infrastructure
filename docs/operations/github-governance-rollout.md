# GitHub governance rollout — 2026-10-28

This implements the [agreed first rollout](../research/github-modernisation.md)
from infrastructure `422de31`, after auto-merge PR #60. Repository ownership,
subscriptions, merge methods, deployment ref policies, and Booze's strict `ci`
check are retained. No paid feature was purchased.

## Changes and evidence

- **Governance CI:** retain the required `tflint` aggregate and include recursive
  formatting, validation and TFLint for all four roots, and all three mocked
  module test suites. Local validation/TFLint passed for four roots; eight test
  cases pass. The sole-maintainer merge-contract test fails with the old
  unresolved-thread default and passes after restoring the change.
- **Merge contract:** add eight missing PR rules, resolve review threads, retain
  zero required approvals, remove routine status-check bypasses on Braze,
  Censusworkspace and Contentful, and remove GraphQL's latent code-owner review
  requirement. GraphQL's unrelated branch-deletion bypass and Contentful's
  existing release-tag bypass are preserved.
- **CodeQL:** add the missing gates for Booze, GraphQL Schema Registry and
  infrastructure at the existing `high_or_higher` security / `errors` thresholds.
  The preflight found recent successful CodeQL analyses on all 11 public
  repositories. This is result-production evidence, not a new security scan.
- **Actions:** enforce SHA pinning at organization scope and in all seven
  personal repositories. The source preflight found 94 workflows with explicit
  permissions and 323 SHA-pinned external workflow references; the inspected
  nested action reference was also pinned. Personal token defaults now read
  `read`; the three changed repositories were Booze, Perfumery and Contentful.
  Their `can_approve_pull_request_reviews` values remained `true`.
- **Security ownership:** private failures were explicitly reported by GitHub
  as “Not purchased”. Created the free private profile, attached exactly four
  private deployment repositories, and restricted the existing profile default
  to public repositories. All nine attachments now report `enforced`.
  API checks verify Dependabot alerts/updates enabled on all nine, public secret
  scanning/push protection and CodeQL default setup enabled, and paid private
  scanning disabled. Public validity, extended metadata, generic-pattern and AI
  profile settings now match unavailable extras instead of requesting them.
  See the [authoritative policy and procedure](github-security-ownership.md).
- **State handoff:** backed up the organization state in the existing Atlantis
  backend environment and forgot ten security-resource instances using
  `terraform state rm`. These were updates/alerts pairs for atlantis-deploy,
  cyspbot-deploy, cyspbot, cyspbot-app-token-action and infrastructure. No provider
  delete was invoked. The other four repository modules already omitted these
  resources. A fresh state-backed plan has no security-resource deletion,
  recreation, or repository security-setting changes.
- **Contentful release tags:** declare and import live ruleset `21243847` with
  its exact `refs/tags/v*` creation/update/deletion rules and User `742696` always
  bypass. The state-backed plan imports it without any remote change.

## Deployment order and remaining evidence

[Censusworkspace PR #203](https://github.com/cysp/terraform-provider-censusworkspace/pull/203)
removes only the README path filters from its test workflow. Its required test,
CodeQL and Codecov checks pass. Merge it before applying the personal-account
plan so README-only changes can report required tests after bypass removal.
A README-only PR against the merged workflow has not yet been exercised.

The organization plan reports **5 additions, 2 updates, 0 destroys**, consisting
only of four PR rules, one CodeQL rule, SHA enforcement and the action repository's
review-thread requirement. The personal-account plan reports **8 imports, 6
additions, 16 updates, 0 destroys**: seven Actions-permission imports/updates,
the unchanged release-tag import, four PR rules, two CodeQL rules, two existing
PR-rule updates, and seven check-bypass removals. Terraform-managed rule and
SHA-policy changes remain
unapplied until their reviewed plans are applied. The API/UI-owned profile and
token-default changes and non-destructive state handoff are already complete.

Perfumery's private personal-account plan limitation remains: no new rulesets or
auto-merge eligibility are claimed. New dependency review, release immutability,
provenance expansion, disclosure policy, 2FA, and event/actor policies remain
outside this rollout. A complete set of release/bot/reusable-workflow executions
has not been triggered solely to test SHA policy.
