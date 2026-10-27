# GitHub security settings outside Terraform

The locked GitHub provider does not manage organization security configurations
or personal-repository default workflow-token permissions. The reviewed intent
for these exceptions is [security-policy.json](../../github/security-policy.json).
The organization configurations are authoritative for attached repositories;
repository Terraform inputs omit their security settings. Terraform continues to
own supported security settings on personal repositories, Actions SHA policy,
and the organization's default workflow-token permissions.

After changing a profile, repository visibility, attachment, or token default,
run the read-only check with an authenticated GitHub CLI account that can read
these settings:

```sh
python3 scripts/check-github-security-policy.py
```

It checks profile intent, new-repository defaults, actual enforced attachments,
effective repository flags, Dependabot updates and alerts, and personal token
defaults. Missing fields or inaccessible endpoints fail the check. It does not
create configurations, enable paid products, repair drift, or test workflow runs.
GitHub does not expose every effective profile feature through the repository
API; the check makes no claim about unavailable effective fields.

Use the organization **Settings → Advanced Security → Configurations** UI or the
[configuration REST API](https://docs.github.com/en/rest/code-security/configurations)
to reconcile profiles and selected repository attachments. Keep public and
private/internal defaults separate. Changing the public profile's paid extras
requires a new entitlement decision; current subscriptions do not provide them.
The private baseline deliberately enables only free dependency protections.

For personal repository tokens, use **Settings → Actions → General → Workflow
permissions** or `PUT /repos/{owner}/{repo}/actions/permissions/workflow` with
`default_workflow_permissions: read`. Read and preserve
`can_approve_pull_request_reviews`; this rollout does not change that independent
setting. Workflows grant necessary write permissions explicitly.

## Transferring existing Terraform security resources

Omitting an existing `github_repository_dependabot_security_updates` or
`github_repository_vulnerability_alerts` resource is a destructive operation:
the provider disables the corresponding GitHub feature when it deletes the
resource. Before changing its input to `null`:

1. Attach and verify the authoritative organization configuration.
2. Back up the current state in the existing protected backend environment.
3. Use `terraform state rm` for only the transferred security-resource addresses.
   This forgets state without invoking provider deletion.
4. Remove corresponding import blocks, set the transferred inputs to `null`, and
   verify a fresh plan contains no security-resource deletion or recreation.
5. Verify effective GitHub protections again after applying the repository plan.

Do not revert the omission or restore old import blocks during routine rollback:
that would reintroduce competing owners. A reverse ownership transfer needs its
own plan and import after the organization releases those settings. A `removed`
block cannot forget individual instances while the shared module still declares
the resource, even when its count is zero.
