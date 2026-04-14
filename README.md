# claude-review-action

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Website](https://img.shields.io/badge/Website-layered.ai-purple)](https://www.layered.ai/)
[![GitHub](https://img.shields.io/badge/GitHub-layered--ui--rails-black)](https://github.com/layered-ai-public/claude-review-action)
[![Discord](https://img.shields.io/badge/Discord-join-5865F2)](https://discord.gg/aCGqz9Bx)

Reusable GitHub Action for AI-powered code review with Claude. Reviews pull request diffs for bugs, security issues, and risky changes - only flags issues worth fixing.

## What's included

- **Reusable GitHub workflow** - drop-in CI review for any repo
- **Claude Code commands** - local equivalents you can run before pushing

## CI setup

### 1. Add the secret

Add `ANTHROPIC_API_KEY` as a repository or organisation secret.

### 2. Create the caller workflow

Add `.github/workflows/claude_code_review.yml` to your repo:

```yaml
name: Claude Code review

on:
  pull_request:
    types: [opened, synchronize]
  workflow_dispatch:
    inputs:
      pr_number:
        description: PR number to review
        required: true

permissions:
  contents: read
  pull-requests: write
  issues: read
  id-token: write
  actions: read

jobs:
  review:
    uses: layered-ai-public/claude-review-action/.github/workflows/claude-review.yml@main
    with:
      pr_number: ${{ inputs.pr_number }}
    secrets:
      anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

That's it. Pull requests will now get a review comment from Claude.

## Local setup (Claude Code commands)

Run the install script directly:

```sh
curl -fsSL https://raw.githubusercontent.com/layered-ai-public/claude-review-action/main/install-commands.sh | sh
```

Or copy manually:

```sh
mkdir -p ~/.claude/commands
cp commands/code-review.md ~/.claude/commands/code-review.md
cp commands/code-review-and-fix.md ~/.claude/commands/code-review-and-fix.md
```

Then in any project use the Claude Code slash commands:

- `/code-review` - review the current branch (read-only)
- `/code-review-and-fix` - review and automatically fix issues, repeating until clean or 3 cycles
- `/code-review main` or `/code-review-and-fix develop` - review against a specific base

By default the commands auto-detect `main` or `master` as the base branch. Pass a specific base when that default is wrong - for example when reviewing against a `develop` branch, a release branch, or another feature branch in a stacked PR workflow.

## Customising the review prompt

To override the default review behaviour, add a `.github/claude-review-prompt.md` file to your repo. Instructions in this file take precedence over the built-in defaults - you only need to specify what you want to change.

```sh
mkdir -p .github
touch .github/claude-review-prompt.md
```

Example `.github/claude-review-prompt.md`:

```markdown
## Additional rules

- All database migrations must include a rollback step.
- Flag any use of `eval()` as CRITICAL.
- Ignore changes to generated files in `src/generated/`.

## Severity overrides

- LOW severity is also acceptable for this repo - report style issues in test files.
```

This works for both CI and local commands. The reviewer reads your overrides first, applies them, and falls back to the built-in defaults for anything you didn't override.

## How it works

The reviewer looks at the diff between your branch and the base, reads surrounding code to verify assumptions, and reports issues at MEDIUM severity or above. It won't flag style nits, naming opinions, or design preferences - only things worth changing.

Severity levels:

- **CRITICAL** - data loss, security vulnerability, silent corruption, or outage risk
- **HIGH** - likely bug, race condition, or serious logic error
- **MEDIUM** - meaningful code smell or unclear intent that risks future bugs

If your repo has a `CLAUDE.md` or `AGENTS.md`, the reviewer will read it for project-specific guidance.

## License

Released under the [Apache 2.0 License](LICENSE).

Copyright 2026 LAYERED AI LIMITED (UK company number: 17056830). See [NOTICE](NOTICE) for attribution details.
