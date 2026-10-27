# GitHub resource modernisation opportunities

Research date: 2026-10-27. Status: first rollout in progress. Research baseline: `cbb96ff`; implementation branch starts from `422de31` after auto-merge PR #60 merged. See [rollout record](../operations/github-governance-rollout.md) for implementation evidence and remaining work.

The strongest opportunity is to make existing policy reliable and inspectable: reconcile the organization security configuration with its effective repository settings, enforce the Actions practices already followed by the workflows, and bring externally managed protections under an explicit owner. A fleet-wide feature rollout or provider upgrade would miss the most concrete gaps.

The agreed constraints are to preserve sole-maintainer operation and start with current repository owners and subscriptions. Paid products and ownership transfers remain separate decisions.

The interview has also settled these policy requirements:

- Enforce full-SHA action references and read-only default `GITHUB_TOKEN` permissions, with explicit job-level write grants where needed.
- Require pull requests and checks for routine default-branch changes, including maintainer and bot changes, with zero mandatory human approvals. Use explicit emergency ruleset editing and reconciliation rather than routine check bypasses.
- Give each security setting one authoritative owner: organization security configurations for attached repositories, Terraform where those configurations do not apply and the provider supports the setting, and documented API/UI ownership where it does not. Reconcile failed/removed attachments within current entitlements before broadening coverage.

- Do not introduce a blanket requirement for checks to include the latest default-branch changes; permit concurrent work without requiring every branch to refresh after another merges. Retain Booze's existing current-base CI exception for migration changes.
- Require resolution of review threads before merging, while retaining zero mandatory human approvals.
- Require CodeQL results across all 11 public repositories at the existing high/critical security and analysis-error thresholds. Confirm result production before adding the three missing gates.
- Keep the first rollout focused on these governance controls, security-policy reconciliation, importing existing protections, and governance CI. Defer new dependency-review gates, release immutability/provenance changes, vulnerability-reporting changes, mandatory 2FA, and new Actions event/actor policies to separate follow-ups.

These decisions settle the first-rollout proposal, which was subsequently approved for implementation. The later opportunities remain deferred.

## Evidence and limits

The inventory contains 16 managed repositories: nine under the `chikachow` organization and seven under the `cysp` personal account. Eleven are public; four organization deployment repositories and `cysp/perfumery` are private. `chikachow` reports a Team plan. The prior auto-merge work verified the capability enabled on 15 repositories; the private personal Perfumery repository retains its plan-dependent exception. Sources: [repository declarations](../../github), [organization API](https://api.github.com/orgs/chikachow), and [auto-merge availability](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-auto-merge-for-pull-requests-in-your-repository).

Authenticated read-only evidence collected during this research covers repository metadata, security-configuration attachment status, effective branch rules, Actions settings, workflow files on current default branches, and recent CodeQL analyses. The evidence distinguishes configuration intent, attachment state, and effective settings. A missing API field is unknown, not disabled. A 403 can indicate entitlement rather than a missing configuration. These checks did not execute application tests, prove every workflow path safe, or run a state-backed Terraform plan.

Primary API evidence can be refreshed using the following endpoints; these are dated observations, not claims that remote state cannot change:

| Evidence | Source |
| --- | --- |
| Repository features, visibility, merge methods, effective security flags | `GET /repos/{owner}/{repo}`; [repository API contract](https://docs.github.com/en/rest/repos/repos#get-a-repository) |
| Default-branch rules and individual rulesets | `GET /repos/{owner}/{repo}/rules/branches/main` and `/rulesets`; [rules API contract](https://docs.github.com/en/rest/repos/rules) |
| SHA policy and token defaults | `GET /repos/{owner}/{repo}/actions/permissions` and `/actions/permissions/workflow`; [Actions permissions contract](https://docs.github.com/en/rest/actions/permissions) |
| Organization security intent and defaults | [configuration 249719](https://api.github.com/orgs/chikachow/code-security/configurations/249719), [defaults](https://api.github.com/orgs/chikachow/code-security/configurations/defaults) |
| Actual attachment outcome | `GET /repos/{owner}/{repo}/code-security-configuration`; [configuration API contract](https://docs.github.com/en/rest/code-security/configurations) |
| Implemented workflow behavior | Default-branch `.github/workflows` through the [Contents API](https://docs.github.com/en/rest/repos/contents#get-repository-content), retaining blob SHAs during inspection |

## Recommended order

| Priority | Opportunity | Concrete benefit | Cost or prerequisite |
| --- | --- | --- | --- |
| 1 | Resolve security-configuration intent/effect discrepancies | Avoid claiming security coverage that failed to attach | Determine failure reasons and existing entitlements; select one owner per setting |
| 1 | Enforce existing SHA-pinning practice | Prevent future mutable action references | Verify all action/composite/reusable paths and bot workflows before enforcement |
| Monitor | Track the upcoming public `pull_request_target` policy | Preserve compatibility with GitHub's rollout | No current workflow uses this event; no migration or exemption is justified now |
| 1 | Import existing release protection and close reporting gaps | Preserve already-used safeguards and provide a private disclosure route | Confirm recovery procedure and report responder |
| 2 | Make automated merge guarantees explicit | Block known bad changes without requiring a second human | Choose PR, CodeQL, dependency-review, and current-base guarantees separately |
| 2 | Unify organization-wide invariants only where they are shared | Reduce omission/drift while preserving repository-specific CI contracts | Overlap old and new rules during migration; verify effective rules |
| 2 | Close targeted provenance/release-integrity gaps | Make released bytes verifiable and harder to replace | Check release publication order and actual consumers |
| Separate | Paid/preview features and ownership changes | Expand available controls where there is demonstrated value | Explicit cost, compatibility, and maintenance decision |

## 1. Reconcile the security configuration before adding more toggles

The organization already has an enforced security configuration, ID `249719`, defaulted to all newly created repositories. It requests CodeQL default setup, dependency submission, Dependabot, secret scanning, push protection, generic patterns, validity checks, and delegated controls. Its `private_vulnerability_reporting` is `not_set`. Attachment status is **enforced** on all five public `chikachow` repositories, **failed** on `atlantis-deploy`, `cyspbot-deploy`, and `github-app-token-broker-deploy`, and **removed** on `cloudflare-workload-identity-deploy`. Sources: [configuration](https://api.github.com/orgs/chikachow/code-security/configurations/249719), [defaults](https://api.github.com/orgs/chikachow/code-security/configurations/defaults), and the per-repository attachment endpoint described above.

The effective repository API nevertheless reports non-provider patterns and validity checks disabled on those public repositories. All four private deployment repositories report secret scanning/push protection and Code Security disabled. This is a discrepancy to diagnose, not evidence that nobody selected the feature. The attachment response does not establish why application failed. The profile also requests `advanced_security = enabled`, so blindly reattaching it could cross a licensing boundary. GitHub Code Security and Secret Protection for private repositories require eligible paid products. [Product availability](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)

**Proposal:** inspect attachment errors in the organization security UI/API, establish the effective licensed capabilities, then choose a single authoritative owner for each setting. Keep organization-enforced settings out of competing repository-level Terraform resources. The repository already expresses this boundary by setting Dependabot-related inputs to `null` on two deployment repositories. Preserve that omission semantics during any refactor. [Current module lifecycle](../../modules/github-repository/main.tf), [deployment example](../../github/chikachow/github_repository_github_app_token_broker_deploy.tf)

For capabilities outside the provider, prefer an explicit, small audited API/UI ownership exception plus read-only drift checks over an opaque provisioner embedded in Terraform. Reconcile three values: desired profile, attachment status, and effective repository setting. Acceptance evidence should include a converged attachment and effective flag; profile contents alone are insufficient. This is a design recommendation.

## 2. Turn existing Actions discipline into policy

The workflow audit inspected 94 workflow files: every file declares top-level permissions, and all 323 literal external `uses:` references are pinned to a full 40-character SHA. Local action definitions were also inspected; the one nested external action reference is SHA-pinned. All 16 repositories nevertheless report `sha_pinning_required = false`. The organization configuration explicitly keeps that policy false. Therefore the opportunity is enforcement and regression prevention, not mass rewriting already-pinned workflows. Sources: [organization policy](../../github/chikachow/github_organization.tf), dated default-branch workflow reads, and the Actions permissions endpoints above.

**Proposal:** pilot SHA enforcement against the already-compatible source configuration, then verify representative bot, maintainer, composite-action, and reusable-workflow runs. Third-party action internals and runtime downloads were not audited. GitHub's current documentation says the policy covers actions, including GitHub-owned actions; reusable workflows may still be referenced by tags. Thus policy enforcement does not remove the need to pin reusable workflows deliberately. The provider supports this setting in `github_actions_repository_permissions` and organization permissions. [GitHub policy semantics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository), [released provider resource](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/actions_repository_permissions.md)

`cysp/booze`, `cysp/perfumery`, and `cysp/terraform-provider-contentful` default their workflow token to write. Since current workflow files already declare permissions, changing the fallback to read primarily protects future omissions; it is not proof that today's jobs use excess permissions. Audit actual permissions and automation that creates/approves PRs before changing them. GitHub recommends read-only defaults with job-specific escalation. [Secure use guidance](https://docs.github.com/en/actions/reference/security/secure-use)

The released provider has organization/enterprise workflow-permission resources but no repository workflow-default-permission resource. Do not invent `github_actions_repository_workflow_permissions`; a current-owner rollout needs API/UI management for the personal repositories or upstream provider support. [v6.13.0 resource registry](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/provider.go)

A restrictive third-party action allowlist is a separate decision from SHA pinning: it limits approved suppliers but adds maintenance for legitimate new actions. Start with SHA enforcement unless there is a concrete supplier-trust requirement. This is a recommendation, not a necessary consequence of `allowed_actions = all`.

### Time-sensitive workflow policy

GitHub currently documents a default public-repository event policy that blocks `pull_request_target`, initially in evaluate mode, with enforcement on **2026-12-02** for affected repositories. It does not replace applicable policies already configured and does not apply to private/internal repositories. Inspect actual policies and event usage before proposing exemptions. Migrate unnecessary privileged triggers; retain a narrowly justified exemption only for workflows that genuinely need the base-repository trust boundary. [Official rollout and security model](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target)

Workflow execution policies can scope allowed actors and events. They can also block intended Dependabot/custom bot automation if the relevant identities are omitted. No inspected workflow uses `pull_request_target`, so there is no identified migration needed for the announced deadline. Repository policy queries returned zero policies on all 15 eligible repositories; Perfumery returned a plan restriction, and the organization policy endpoint returned 404 with no established cause. The rollout should include representative bot and maintainer-triggered runs. [Workflow execution policy](https://docs.github.com/en/actions/how-tos/administer/control-workflow-execution)

## 3. Make automated merge guarantees deliberate

The estate already uses rulesets, expected GitHub App identities for status checks, and CodeQL. It does not need a blanket migration from legacy branch protection. The prior audit found successful CodeQL analyses on all 11 public repositories. `booze`, `graphql-schema-registry`, and `infrastructure` have no CodeQL merge rule despite those analyses. Requiring CodeQL results there is a concrete candidate; confirm supported language/configuration and expected result production before enabling the rule. [Current declarations](../../github), [GitHub code-scanning merge protection](https://docs.github.com/en/code-security/how-tos/scan-code-for-vulnerabilities/manage-your-configuration/set-code-scanning-merge-protection)

Eight eligible repositories currently lack a PR requirement: `chikachow/cloudflare-workload-identity`, `cyspbot`, `github-app-token-broker`, `infrastructure`, and `cysp/booze`, `terraform-provider-braze`, `terraform-provider-censusworkspace`, `terraform-provider-contentful`. The classic branch-protection endpoint was checked as well, so these are not rules hidden in legacy protection. Their other rulesets remain active. A PR requirement with zero mandatory human approvals can preserve sole-maintainer operation while making changes reviewable. It is different from requiring a second person's approval. The interview now requires PRs for routine default-branch changes with zero human approvals and resolved review threads. It rejects a new blanket current-base check requirement and retains Booze's existing exception. Most status rules currently use `strict_required_status_checks_policy = false`; `booze` is an explicit stricter exception. [Module defaults](../../modules/github-repository-ruleset-required-status-checks/variables.tf), [pull-request module](../../modules/github-repository-ruleset-require-pull-request/variables.tf), [GitHub rules semantics](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)

The accepted no-routine-check-bypass policy requires reconciling existing admin/maintain-role exemptions in Braze, Censusworkspace, and Contentful. The GraphQL Schema Registry also requires code-owner review even though no `CODEOWNERS` file was found in GitHub's three supported locations; remove this latent approval requirement to make the zero-human-approvals contract explicit. Inspected update workflows create PRs, and the app-token action's direct pushes target tags, not the default branch; external scripts and bots remain outside that workflow-only evidence. [Braze rules](../../github/cysp/github_repository_terraform_provider_braze.tf), [Censusworkspace rules](../../github/cysp/github_repository_terraform_provider_censusworkspace.tf), [Contentful rules](../../github/cysp/github_repository_terraform_provider_contentful.tf), [GraphQL rules](../../github/cysp/github_repository_graphql_schema_registry.tf)

Before removing bypasses, ensure required checks report for every permitted PR. Censusworkspace's test workflow excludes README-only changes even though `test` and `codecov/project` are required. Design an always-reporting result for that path before tightening enforcement; simply removing the bypass can leave those PRs unable to merge. This is an existing check-coverage mismatch, not a new problem caused by strict current-base checks. [Censusworkspace workflow](https://github.com/cysp/terraform-provider-censusworkspace/blob/main/.github/workflows/test.yml#L7), [required checks](../../github/cysp/github_repository_terraform_provider_censusworkspace.tf)

No inspected workflow contained a literal dependency-review action. A small public-repository pilot can reject newly introduced known-vulnerable dependencies before merge. Choose a severity threshold and exception process after checking dependency-graph coverage; do not combine that rollout with a new license policy by accident. Public repositories are eligible; private repositories need Code Security or Advanced Security. [Dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review), [configuration](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/manage-your-dependency-security/configure-dependency-review-action)

Codecov's exact behavior without a new upload remains unverified; the missing required `test` result is independently established by the workflow filter. Treat coverage-service behavior as a separate acceptance check.

Preserve Atlantis's `ATLANTIS_GH_ALLOW_MERGEABLE_BYPASS_APPLY` setting. It lets Atlantis ignore its own pending apply status when deciding whether it may apply; it does not bypass GitHub's merge checks. Removing it while keeping `atlantis/apply` required creates a circular dependency. Atlantis already uses merge checkout and requires undiverged plans/applies, so stricter branch checks add rerun/replan cost rather than introducing plan freshness from scratch. [Server requirements](https://github.com/chikachow/atlantis-deploy/blob/main/atlantis/repos.yaml#L4), [server settings](https://github.com/chikachow/atlantis-deploy/blob/main/fly.toml#L16), [Atlantis behavior](https://www.runatlantis.io/docs/command-requirements#github)

**Do not default to merge queues.** They apply to organization-owned public repositories, or private organization repositories on Enterprise Cloud. They cannot cover the current `cysp` personal repositories. Required checks also need `merge_group` support, absent from the inspected workflows; external checks such as Atlantis require separate integration evidence. A queue is worth piloting only where concurrent merges cause a measured problem. [Availability and semantics](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue), [required-check events](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks)

## 4. Preserve external protections and close the disclosure route

Contentful has a live `Protect release tags` ruleset, ID `21243847`, absent from this repository's Terraform declarations. Importing the exact existing rule would capture an existing guarantee without inventing a stronger one. First compare all fields and bypass actors, then require a no-change plan. [Live rule](https://api.github.com/repos/cysp/terraform-provider-contentful/rulesets/21243847), [Contentful declaration](../../github/cysp/github_repository_terraform_provider_contentful.tf)

Private vulnerability reporting is disabled on five public repositories: `chikachow/cloudflare-workload-identity`, `chikachow/cyspbot`, `chikachow/github-app-token-broker`, `cysp/booze`, and `cysp/graphql-schema-registry`. Enablement is a low-cost candidate once someone owns report triage and notifications. The feature creates a private reporting route; a `SECURITY.md` alone does not enable it. GitHub's notification subscriptions still matter. [Reporting setup](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository), [reporting behavior](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)

The organization reports that mandatory 2FA is disabled. The current filtered member and outside-collaborator API lists returned zero accounts without 2FA; this supports a small policy change rather than a claim that current users lack 2FA. Requiring 2FA is a separate worthwhile identity-policy proposal, subject to recovery and service-account readiness. The filtered lists establish use of some 2FA, not compliance with GitHub's stronger secure-method requirement; enforce secure methods only after that additional preflight. It is not a repository Terraform toggle in the released provider. Non-compliant outside collaborators can lose access, while members may lose resource access until compliant; do not turn this into an unreviewed bulk change. [Organization API](https://api.github.com/orgs/chikachow), [GitHub preparation requirements](https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-two-factor-authentication-for-your-organization/preparing-to-require-two-factor-authentication-in-your-organization), [provider organization schema](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/organization_settings.md)

## 5. Use organization-level policy only for actual invariants

GitHub Team supports organization rulesets. A small `chikachow` baseline could hold universally intended default-branch invariants, while repository-specific required check names, environments, and exceptions stay beside each repository. The `cysp` repositories would retain repository rulesets. This reduces omission risk; it is not an argument to replace every declaration with a large data-driven matrix. [Organization rulesets](https://docs.github.com/en/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization)

Organization required workflows can enforce a shared workflow by source repository/path/ref and are supported by this provider. They are useful only if there is a genuinely shared check. Filters in the supported trigger configuration are ignored; most CodeQL actions cannot run in ruleset workflows, so preserve the existing CodeQL-specific protection mechanism. Bootstrap behavior and open PRs need explicit migration checks. [Provider required-workflow schema](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/organization_ruleset.md), [GitHub operational limits](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules)

Migrate by adding the new rule, verifying the combined effective rules and representative PRs, and only then removing redundant old rules. Required checks whose exact names differ across repositories should remain explicit. For shared-module changes, confirm Atlantis module dependency tracking or add explicit module path triggers; the YAML alone does not establish whether server-side `ATLANTIS_AUTOPLAN_MODULES` already covers them. [Current Atlantis configuration](../../atlantis.yaml)

### Verify governance changes at their existing boundary

The infrastructure CI workflow currently runs TFLint and an aggregate status. The repository already has mocked tests for repository defaults and required-status-check defaults, but that workflow does not run them, formatting checks, or Terraform validation. Add those existing checks to the relevant CI gate before extending policy; no new test framework is needed. Keep the required aggregate check name stable. [Current workflow](../../.github/workflows/tflint.yml), [repository tests](../../modules/github-repository/tests/defaults.tftest.hcl), [ruleset tests](../../modules/github-repository-ruleset-required-status-checks/tests/defaults.tftest.hcl)

## 6. Target release integrity and deployment trust gaps

Braze, Censusworkspace, and Contentful already use `actions/attest-build-provenance`; Typesense does not. The useful question is whether Typesense should reach the same release contract, and whether consumers verify the existing attestations. Merely producing attestations does not deliver the benefit unless someone verifies them. Public repositories are eligible under current plans; private repositories require Enterprise Cloud. [Artifact attestation guidance](https://docs.github.com/en/actions/concepts/security/artifact-attestations), [availability](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)

Immutable releases are a separate candidate for published provider binaries. They apply to future releases and prevent replacing published assets or moving/deleting the release's tag while it exists. Release pipelines should finish uploading assets to a draft before publication. The dedicated immutable-release endpoint reports `enabled = false` and `enforced_by_owner = false` on all 16 repositories. Pilot this on a published provider only after checking its release publication order and recovery procedure. The released provider repository schema has no immutability argument, so this needs explicit API/UI ownership or upstream support. [Immutable release API](https://docs.github.com/en/rest/repos/repos#check-if-immutable-releases-are-enabled-for-a-repository), [immutable release configuration](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/establish-provenance-and-integrity/prevent-release-changes), [release editing constraints](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)

The compatibility concern is concrete: Contentful and Braze require an already-published release before invoking GoReleaser to upload assets. Their sequence must change before release immutability is enabled. Separately, the app-token action deliberately moves major/minor compatibility tags; blanket tag-update restrictions would change that public contract. Keep immutable version tags distinct from those moving aliases. [Contentful release workflow](https://github.com/cysp/terraform-provider-contentful/blob/main/.github/workflows/release.yml#L33), [Braze release workflow](https://github.com/cysp/terraform-provider-braze/blob/main/.github/workflows/release.yml), [action tag workflow](https://github.com/chikachow/cyspbot-app-token-action/blob/main/.github/workflows/prepare-release.yml#L76)

The production environments in the four private deployment repositories already restrict deployment workflow refs to `main`; the source repositories' production environments have no branch policy in current Terraform. Preserve the README's distinction between the workflow run's ref and the revision a job checks out. The deployment workflows already constrain source revisions: Atlantis deploys `github.sha` after validations, and the Cyspbot, workload-identity, and token-broker deploy workflows compare successful CI revisions with current `main` before deploying. Booze deploys its successful CI SHA without that freshness recheck; change this only if stale-release prevention is a required guarantee. A useful next step is to verify deployment credentials are bound to the intended environment, repository, audience, and reusable workflow, where supported. OIDC subject customisation is provider-supported but changing subjects without coordinated relying-party trust changes can break deployment. Existing broker/issuer resources mean an assumption that OIDC is absent would be wrong. [Existing deployment rule](../../github/chikachow/github_repository_cyspbot_deploy.tf), [README guarantee](../../README.md), [OIDC reusable-workflow trust](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-with-reusable-workflows)

## Provider and product boundaries

The locked provider is already `6.13.0`, matching the newest release listed during this research, and both GitHub roots use its rewritten API client. A generic upgrade is not a concrete proposal. The `code_security` schema still lacks `CodeSecurity` read/write references in that tagged implementation; the module's workaround mentions 6.12.1, but its underlying concern remains. Reproduce support before removing the safeguard. [Release](https://github.com/integrations/terraform-provider-github/releases/tag/v6.13.0), [tagged implementation](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/resource_github_repository.go), [current provider setup](../../github/chikachow/providers.tf)

The released resource registry does not expose organization security configurations, private-vulnerability-reporting enablement, or CodeQL default setup. Native newer GitHub capabilities therefore do not imply that this Terraform version can manage them. Preserve a clear ownership boundary and avoid claiming schema presence proves round-trip support. [Released resource registry](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/provider.go)

Keep these outside the initial baseline:

- **Perfumery GitHub Pro:** would address the private personal repository's ruleset/auto-merge eligibility, but is a separate spending decision. Moving it to an organization has a different migration cost and should not be used merely to evade the decision.
- **Private Code Security / Secret Protection:** diagnose current attachment failures and entitlement first; an upgrade is not assumed approved.
- **Actions dependency lockfiles:** Enterprise Cloud-only and currently public preview. The existing SHA-pinned practice is the appropriate present baseline. [Current eligibility and preview status](https://docs.github.com/en/actions/how-tos/secure-your-work/lock-workflow-dependencies)
- **Native secret-scan merge gates, code-quality/coverage rules, and AI review:** promising, but assess entitlement, maturity, provider support, consumer value, and overlap before replacing established checks. Newness alone is insufficient.
- **Wikis, Discussions, Projects, templates, and additional merge methods:** their disabled state is not a defect without an actual collaboration or publishing requirement.

## Decision tree for the interview

```text
Settled first-rollout requirements
├─ preserve sole-maintainer operation; current owners/plans first
├─ enforce action SHA pinning and read-only token defaults
├─ routine changes use PRs and checks, with zero human approvals
├─ require resolved review threads
├─ require consistent CodeQL gates at existing thresholds
├─ no new blanket current-base CI requirement; retain Booze's existing exception
├─ emergency rule editing/reconciliation instead of routine check bypasses
├─ one authority per security setting, including explicit provider-gap ownership
└─ import existing protections and run existing governance verification in CI

Deferred to separate follow-ups
├─ new dependency-review gates and severity/license policies
├─ release immutability/provenance expansion and artifact consumers
├─ vulnerability-reporting ownership and notification policy
├─ mandatory 2FA and stronger authentication requirements
├─ new Actions event/actor policies
└─ paid products, ownership transfers, Enterprise/preview features
```

Booze's exception was introduced by commit [`44c7ef2`](https://github.com/chikachow/infrastructure/commit/44c7ef2d13b83436a15c073709a6df4a9e5c0c9c), titled "Require current-base CI for Booze migration changes". It currently applies to the repository's required `ci` check. The agreed decision is to retain this existing safeguard while adding no further strict-current-base requirements.

No modernization should be folded into the auto-merge PR merely because the work shares this checkout.

## Agreed first rollout and acceptance evidence

1. **Prepare reliable governance checks.** Add formatting, validation, and the existing mocked module tests to the infrastructure CI gate. Preserve its required aggregate check name. Correct Censusworkspace's README-only required-test reporting before removing check bypasses; verify Codecov behavior separately.
2. **Enforce existing Actions conventions.** Require full-SHA action references and read-only token defaults. Preserve explicit job-level writes and verify representative maintainer, bot, release, composite-action, and reusable-workflow runs. Use explicit API/UI ownership for repository token defaults where the provider lacks support.
3. **Apply the agreed merge contract.** Require PRs, required checks, and resolved review threads across eligible repositories, with zero mandatory human approvals. Reconcile existing routine check bypasses and GraphQL's latent code-owner approval requirement. Add the three missing public-repository CodeQL gates using the established thresholds. Preserve Booze's strict check, existing deployment guarantees, and Atlantis's pre-apply status exception; introduce no new current-base requirements or merge queues.
4. **Reconcile security authority within current entitlements.** Diagnose failed/removed attachments and differences between configured and effective settings. Assign one owner per setting and verify both attachment status and effective behavior. Do not purchase products or enable chargeable capabilities merely to make the profile attach.
5. **Capture existing unmanaged protection.** Import Contentful's release-tag ruleset with its existing semantics and require a no-change plan. This does not authorize broad new tag restrictions or immutable releases.

For each change, establish the intended before/after behavior, verify the effective GitHub configuration, and exercise the affected PR or workflow boundary. Keep reviewable changes separate from the existing auto-merge PR. Application workflow changes required to preserve mergeability belong with their corresponding policy rollout; unrelated feature expansion remains deferred.
