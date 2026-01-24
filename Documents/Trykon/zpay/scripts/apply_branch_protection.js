// scripts/apply_branch_protection.js
// Usage: set GITHUB_TOKEN in env and run: node scripts/apply_branch_protection.js
// It will apply branch protection on the specified branch (default: main).

const { Octokit } = require('@octokit/rest');

async function run() {
  const token = process.env.GITHUB_TOKEN || process.env.BRANCH_PROTECTION_TOKEN;
  if (!token) {
    console.error('GITHUB_TOKEN or BRANCH_PROTECTION_TOKEN env var is required');
    process.exit(1);
  }

  const repoFull = process.env.GITHUB_REPOSITORY;
  if (!repoFull) {
    console.error('GITHUB_REPOSITORY env var is required (owner/repo)');
    process.exit(1);
  }

  const [owner, repo] = repoFull.split('/');
  const branch = process.env.BRANCH || 'main';
  const statusChecks = (process.env.STATUS_CHECKS || 'rules-unit-tests,emulator-e2e').split(',').map(s => s.trim()).filter(Boolean);
  const reviewCount = Number(process.env.REVIEW_COUNT || '1');

  const octokit = new Octokit({ auth: token });

  try {
    await octokit.rest.repos.updateBranchProtection({
      owner,
      repo,
      branch,
      required_status_checks: {
        strict: true,
        contexts: statusChecks,
      },
      enforce_admins: true,
      required_pull_request_reviews: {
        required_approving_review_count: reviewCount,
      },
      restrictions: null,
    });

    console.log(`Applied branch protection for ${owner}/${repo}@${branch}`);
  } catch (e) {
    console.error('Failed to apply branch protection:', e);
    process.exit(1);
  }
}

run();
