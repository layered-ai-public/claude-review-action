# Changelog

All notable changes to this project will be documented in this file. This project follows [Semantic Versioning](https://semver.org/).

## [1.1.1] - 2026-08-09

### Fixed

- Restore the required `@ref` on `anthropics/claude-code-action` (now `@v1`) — without it the runner failed to parse `action.yml` and every review run errored before starting

## [1.1.0] - 2026-08-09

### Changed

- Reviews now read the diff from the local checkout with `git diff` instead of `gh pr diff`, so the reviewed code always matches the checked-out SHA
- The review step tracks the latest `anthropics/claude-code-action` instead of a pinned `v1.0.88`

### Added

- Concurrency group on the reusable workflow — a new push to a PR cancels any in-flight review run

### Fixed

- Checkout is pinned to the PR head SHA (falling back to `refs/pull/{n}/head`), so `pull_request` runs no longer land on the lagging merge ref and `workflow_dispatch` runs no longer review the default branch
- Base ref resolution uses `pull_request.base.ref` with `repository.default_branch` as fallback, fixing the malformed `git diff origin/...HEAD` on `workflow_dispatch` runs

## [1.0.1] - 2026-04-15

### Fixed

- Fix `.github/claude-review` changed to `.github/claude-review-action` across README, prompt, and commands
- Fix install script cleaner — now only removes its own files

## [1.0.0] - 2026-04-15

- GitHub Action for AI-powered code review on pull requests using Claude
- Claude Code slash commands: `/code-review` (read-only) and `/code-review-and-fix` (auto-fix with up to 3 cycles)
- Auto-detect `main` or `master` as base branch, with manual override support
- Customisable review prompt via `.github/claude-review-action/prompt.md`
- Reusable workflow for easy CI integration
- One-line install script for local Claude Code commands
- Reads `CLAUDE.md` and `AGENTS.md` for project-specific guidance
- Reports only MEDIUM severity and above — no style nits or naming opinions
