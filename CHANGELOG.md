# Changelog

All notable changes to this project will be documented in this file. This project follows [Semantic Versioning](https://semver.org/).

## [1.3.0] - 2026-08-14

### Changed

- Added a `model` input, defaulting to `claude-sonnet-5`, passed through to `claude_args` as `--model`. Previously the model was left to whatever `anthropics/claude-code-action` defaulted to, which could resolve to a different (and pricier) model without warning

## [1.2.0] - 2026-08-13

### Changed

- Severity is now assigned by demonstrated consequence rather than by subject matter. Every finding must carry a concrete failure scenario — the input or state, then the wrong result — and findings without one are dropped rather than reported at a lower severity. Code touching authentication, payments, or user data no longer reaches CRITICAL on subject matter alone
- Severity is trigger **and** impact. A nameable trigger alone does not lift a finding above MEDIUM, so an obvious trigger with trivial consequence — a misspelled log line, a wrong label — stays MEDIUM and does not block the PR. Only CRITICAL and HIGH block
- Added a LOW severity band for style, naming, preference, and untriggerable concerns, which is discarded silently. Previously MEDIUM was the lowest band available, so weak findings were promoted into it rather than dropped
- Issues are now reported as one block per finding with an explicit **Trigger** line, instead of a table. The table was unreadable in GitHub's narrow PR column once the trigger had to fit in a cell
- `✅ Ship` is now reserved for reviews with no findings at all. MEDIUM-only reviews get `🟧 Ship (medium findings to address)`, renamed from `Ship (with known minor issues)` — the old wording implied minor findings were expected output
- The single-pass instruction now states that completeness means every real issue, not every observation, and that a review with no issues is a successful review

### Added

- Guidance for partial context: the reviewer is told it will often see only one side of a boundary (a frontend consuming an API, a client of a library) and must look for the contract before flagging missing defensive handling of a value the code treats as guaranteed. Unverified assumptions go in a dedicated **Assumptions** line rather than becoming findings, and `/code-review-and-fix` will not apply a fix based on one
- A self-check pass before output: each finding is re-examined with the aim of disproving it, and dropped if it cannot be defended
- `install-commands.sh` now installs from the local working tree when run from a checkout, reporting the branch and warning about uncommitted changes in `commands/`, so a prompt change can be tested before it is merged. Detection is based on the script's own location rather than the working directory, so `curl | sh` still installs from `main` wherever it is run. `--local` and `--remote` force either source
- A `fixtures/` set of six known diffs with expected outcomes, and `fixtures/run.sh` to build a throwaway repo for any one of them. Three expect no findings (clean refactor, style-only churn, an unseen API contract) and three expect a specific severity (MEDIUM for a trivial log slip, HIGH for an off-by-one, CRITICAL for a reachable SQL injection), so a rubric change can be checked for both over- and under-reporting

## [1.1.2] - 2026-08-09

### Fixed

- Quote the `--allowedTools` value — `claude_args` is parsed with `shell-quote`, so the unquoted list was split on the spaces inside patterns like `Bash(gh pr comment:*)`. None of the `gh` or `git` tools were actually allowlisted, so reviews were generated and then silently discarded when every attempt to post them was denied

### Added

- A verification step that fails the job when the review run completes without a comment landing on the PR, instead of reporting success on a reviewless PR

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
