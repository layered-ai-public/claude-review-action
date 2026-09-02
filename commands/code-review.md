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
- Provide a complete review in a single pass, so the developer does not need a second review cycle. Completeness means every real issue, not every observation. A review with no issues is a successful review - say so plainly and stop. Padding a review with minor findings to look thorough wastes more developer time than a missed nit.

## Partial context is expected

You will often see only one side of a boundary - a frontend consuming an API, a client of a library, a service calling another service. The contract on the other side is not in this diff.

Do not report missing defensive handling of a value the code treats as guaranteed (e.g. a `user` object the API always returns) unless the diff or codebase shows it can actually be absent. Look for the contract first; if you cannot find it, assume the author knows their own API.

If a finding depends on an assumption you could not verify, say so in a single "Assumptions" line after the Issues section - do not convert an unverified assumption into a finding.

## Severity assignment

Assign severity BEFORE deciding what to report. Severity is trigger AND impact; a nameable trigger alone does not raise a finding above MEDIUM.

- **CRITICAL** - You can name the input or state that causes data loss, a security breach, silent corruption, or an outage, and the path to it is reachable from the code as changed.
- **HIGH** - You can name the input or state, AND the resulting behaviour matters: wrong data, broken functionality, or a failure a user would notice and care about.
- **MEDIUM** - Either a nameable trigger whose impact is small (cosmetic, log-only, easily recovered from), or no specific trigger but the change makes a concrete future failure likely and you can say what that failure is.
- **LOW** - Everything else: style, naming, readability, preference, "I would have done it differently", theoretical concerns you cannot trigger.

Every finding must carry a failure scenario: specific input or state, then the specific wrong result. If you cannot write one, the finding is LOW - regardless of how serious the subject matter sounds. Touching authentication, payments, or user data does not by itself make a finding CRITICAL; a demonstrated consequence does.

A trivial defect stays MEDIUM even when the trigger is obvious. A misspelled log message, a wrong label, or a misleading comment is MEDIUM, not HIGH, because the verdict below blocks the PR on HIGH.

Report CRITICAL, HIGH, and MEDIUM. Discard LOW entirely - do not report it as an issue and do not append it as a note or a list of nits. The single exception is the assumption line described above: that line records what you could not verify rather than a finding, and it should still appear when applicable.

## Self-check before output

Before writing the review, re-examine each finding and try to disprove it:

- Read the actual code around it. Does the problem survive contact with what is really there?
- Is the trigger reachable through normal use of this code, or did you have to invent an unusual configuration?
- Would a competent engineer reading this diff call it a real problem, or a matter of taste?
- Verify every `path:line` you are about to cite against the file on disk. Line numbers must come from reading the file itself, never from a diff hunk header, a hunk offset, or memory of where the code "should" be. A citation past the end of the file makes the whole review look like it ran against a different revision.
- If you cannot confirm the line, cite the file path alone and name the symbol (method, constant, class) instead. A path plus a symbol name is always better than an invented line number.

If you cannot defend a finding after that, drop it. Prefer dropping a doubtful finding over reporting it with a caveat.

## Output format

1. **Summary** - One or two sentences on what the PR does.
2. **Issues** - One block per issue, most severe first. Do NOT use a table - reviews are read in narrow PR columns where wide tables become unreadable. Use exactly this shape:

   ```
   #### SEVERITY - `path/to/file.ext:LINE`
   **Trigger:** the input or state, then the wrong result it produces.

   One or two sentences on the issue and what to do about it.
   ```

   Each issue must reference a specific line or change in the diff. Omit this section entirely if there are no issues.
3. **Assumptions** - Only if a finding depended on something you could not verify. A single line. Omit the section otherwise.
4. **Verdict** - with a one-sentence justification:
   - ✅ **Ship** - no findings at all.
   - 🟧 **Ship (medium findings to address)** - MEDIUM findings only, no CRITICAL or HIGH.
   - 🚫 **Changes required** - one or more CRITICAL or HIGH findings.

If no issues are found, keep the response concise and do not add filler commentary.
