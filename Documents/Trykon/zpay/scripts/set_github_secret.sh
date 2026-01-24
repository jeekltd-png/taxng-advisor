#!/usr/bin/env bash
# scripts/set_github_secret.sh
# Simple helper to set a repository secret using gh (GitHub CLI).
# Usage: ./scripts/set_github_secret.sh <secret_name> <secret_value>

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install it: https://cli.github.com/" >&2
  exit 1
fi

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <secret_name> <secret_value>" >&2
  exit 1
fi

SECRET_NAME=$1
SECRET_VALUE=$2

# Set secret for current repo
echo "Setting secret $SECRET_NAME for repo $(gh repo view --json name -q .name)"
printf "%s" "$SECRET_VALUE" | gh secret set "$SECRET_NAME" --body -

echo "Done."
