# Changelog

All notable changes to this project will be documented in this file. This project follows [Semantic Versioning](https://semver.org/).

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
