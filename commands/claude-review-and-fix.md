---
description: Review and fix the current branch against the base branch.
model: opus
---

Review and fix the current branch against the base branch.

The review itself is defined by the `/claude-review` command - this command does not restate it. Run that review, then fix what it finds.

## Base branch

Determine the base branch by checking which of `main` or `master` exists as a remote tracking branch. If the argument $ARGUMENTS is provided, use that as the base instead.

Run `git diff <base>...HEAD` to obtain the diff. If there are no changes, say so and stop.

## Running a review pass

Each review pass is delegated to a subagent running Sonnet, so the review is done by a different model from the one applying the fixes.

Use the Agent tool with `subagent_type: "general-purpose"` and `model: "sonnet"`, and this prompt:

> Invoke the `claude-review` command with the Skill tool, passing `<base>` as its argument, and follow its instructions exactly. Do not modify any files. Return the complete review as your final message, in the output format that command specifies, and nothing else. If no `claude-review` command is available to you, say so instead of reviewing from your own judgement.

Substitute the base branch you determined above. Print the review the subagent returns verbatim, labelled with the pass number (e.g. "Review pass 1").

The `claude-review` command is installed alongside this one, so refer to it by name and let Claude Code resolve it - do not hardcode a path to the file. If the subagent reports it cannot find the command, stop and say that `claude-review` needs to be installed; do not fall back to reviewing from memory or from these instructions, which contain no review rules.

If the Agent tool is unavailable, invoke `claude-review` yourself in this session for each pass and note that it ran on this session's model rather than Sonnet.

## Fix cycle

Run review pass 1. Then, if there are any MEDIUM or above issues:

1. Fix each issue in the code. Keep changes minimal and focused - only fix what the review identified. Do not refactor, reorganise, or "improve" surrounding code.
2. Never apply a fix based on an assumption the review could not verify. If a finding rests on the review's "Assumptions" line, verify it yourself in the codebase first; if you cannot, leave it unfixed and say why.
3. After applying all fixes, run the next review pass the same way. Report only new issues introduced by your fixes - do not re-report issues that have already been resolved.
4. If new issues are found, fix them and review again.
5. Repeat until a clean review pass with no MEDIUM or above issues, or you have completed 3 fix cycles (whichever comes first).

If you hit the 3-cycle limit with issues still remaining, stop and report what's left so it can be resolved manually.

After the final pass, print a short summary of all changes made.

Do not commit the changes.
