#!/usr/bin/env python3
"""Read-only drift check for GitHub settings not supported by the locked provider."""

import json
from pathlib import Path
import subprocess
import sys


POLICY = Path(__file__).resolve().parents[1] / "github/security-policy.json"


def api(endpoint):
    result = subprocess.run(
        ["gh", "api", endpoint], check=True, text=True, capture_output=True
    )
    return json.loads(result.stdout) if result.stdout else None


def compare(label, actual, expected, failures):
    for key, value in expected.items():
        observed = actual.get(key)
        if isinstance(value, dict) and isinstance(observed, dict):
            compare(f"{label}.{key}", observed, value, failures)
        elif observed != value:
            failures.append(f"{label}.{key}: expected {value!r}, got {observed!r}")


def main():
    policy = json.loads(POLICY.read_text())
    failures = []
    organization = policy["organization"]
    defaults = {
        item["configuration"]["id"]: item["default_for_new_repos"]
        for item in api(f"orgs/{organization}/code-security/configurations/defaults")
    }
    for profile in policy["configurations"]:
        identifier = profile["id"]
        endpoint = f"orgs/{organization}/code-security/configurations/{identifier}"
        compare(endpoint, api(endpoint), profile["settings"], failures)
        compare(endpoint, {"default_for_new_repos": defaults.get(identifier)},
                {"default_for_new_repos": profile["default_for_new_repos"]}, failures)
        for repository in profile["repositories"]:
            endpoint = f"repos/{organization}/{repository}"
            compare(endpoint, api(f"{endpoint}/code-security-configuration"),
                    {"status": "enforced", "configuration": {"id": identifier}}, failures)
            compare(endpoint, api(endpoint),
                    {"security_and_analysis": profile["effective_security"]}, failures)
            compare(endpoint, api(f"{endpoint}/automated-security-fixes"),
                    {"enabled": True, "paused": False}, failures)
            if profile["settings"]["code_scanning_default_setup"] == "enabled":
                compare(endpoint, api(f"{endpoint}/code-scanning/default-setup"),
                        {"state": "configured"}, failures)
            # HTTP 204 confirms enabled; HTTP 404/403 is a failed check, not false assurance.
            api(f"{endpoint}/vulnerability-alerts")
        print(f"Checked configuration {identifier} and {len(profile['repositories'])} repositories")
    for repository in policy["read_only_workflow_tokens"]:
        endpoint = f"repos/{repository}/actions/permissions/workflow"
        compare(endpoint, api(endpoint), {"default_workflow_permissions": "read"}, failures)
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("Security configuration, attachment, effective protection and token-default checks passed")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as error:
        print(f"GitHub API check failed: {error.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
