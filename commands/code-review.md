Review the current branch against the base branch.

Determine the base branch by checking which of `main` or `master` exists as a remote tracking branch. If the argument $ARGUMENTS is provided, use that as the base instead.

Run `git diff <base>...HEAD` to obtain the diff. If there are no changes, say so and stop.

You may open files and search the codebase (using grep, find, or reading files) to verify assumptions about changed lines. Do not explore unrelated parts of the repository. Do not write or modify any files.

If a CLAUDE.md or AGENTS.md file exists, read it for repository-specific guidance.

If a `.github/claude-review-action/prompt.md` file exists, read it first. Instructions in that file override the defaults below (severity levels, output format, rules, etc.). Apply the overrides and continue with any remaining defaults that were not replaced.

Print the review directly. Do not post it as a PR comment or anywhere else.

## Review rules

- Only review the changed lines and their immediate visible context in the diff.
- You may (and should) read other files and search the codebase to verify assumptions - e.g. to check whether a method exists, trace a call path, or confirm a constant's value. Do not guess when you can look.
- Do not comment on unchanged code unless a change in the diff breaks it.
- If uncertain whether something is a real issue, look it up in the codebase before reporting it. If you still cannot confirm it, state uncertainty rather than guessing.
- Do not flag standard framework behaviour as an issue (e.g. how Rails helpers handle unknown keys).
- Do not speculate about compatibility with versions, environments, or configurations that are not evidenced in the diff or codebase.
- Do not flag design decisions (API defaults, naming conventions) unless they introduce a concrete bug or safety issue. "I would have done it differently" is not a finding.
- Only flag hypothetical edge cases if they are reachable through normal use of the public API as shown in the diff. Do not invent exotic configurations to create a problem.
- Provide a complete review in a single pass. Include all relevant issues to avoid requiring multiple review cycles.

## Severity threshold

Only report issues at MEDIUM severity or above. Do NOT report style nits, minor readability preferences, naming opinions, or small improvements that do not affect correctness or safety.

Before including any issue, ask yourself: "Would I block the PR or request a change for this?" If the answer is no, do not include it.

- **CRITICAL** - Data loss, security vulnerability, silent corruption, or outage risk.
- **HIGH** - Likely bug, race condition, or serious logic error.
- **MEDIUM** - Meaningful code smell, unclear intent that risks future bugs, or moderate maintainability concern with a concrete consequence.

## Output format

1. **Summary** - One or two sentences on what the PR does.
2. **Issues** - A table with columns: Severity | File | Line(s) | Description. Each issue must reference a specific line or change in the diff. Omit this section entirely if there are no issues.
3. **Verdict** - One of: ✅ **Ship** / 🟧 **Ship (with known minor issues)** / 🚫 **Needs changes** - with a one-sentence justification.

If no issues are found, keep the response concise and do not add filler commentary.
