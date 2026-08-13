# Review fixtures

Known diffs with agreed expected outcomes, for checking that a change to the review
prompt did what it was meant to and nothing else.

The reviewer is a model, so results vary run to run. These fixtures do not prove a
prompt is correct — they catch calibration drift, which is the failure mode this repo
actually suffers from.

## Running one

```bash
./fixtures/run.sh trivial-log-label
```

That builds a throwaway git repo with `base/` committed as `main` and `head/` on a
branch, so `git diff main...HEAD` inside it is exactly the diff under review. It prints
the path. `cd` there, start `claude`, and run `/code-review`.

Read `expected.md` **after** the review, not before — in the same session it primes the
reviewer and the run tells you nothing.

Two things to be careful of. `/code-review` uses your **installed** command from
`~/.claude/commands/`, not this working tree, so run `./install-commands.sh` from the
checkout first — it installs the current branch's prompt and tells you which branch that
was. And to exercise the action rather than the slash command, push the fixture repo to a
scratch remote and point a workflow at the branch — the slash command does not cover the
diff step, `gh pr comment`, or the tool allowlist.

To review a fixture without touching your installed commands at all, pass the prompt
straight to a headless run from inside the fixture repo:

```bash
claude -p "$(cat /path/to/claude-review-action/commands/code-review.md)" \
  --allowedTools "Read,Grep,Glob,Bash(git diff:*),Bash(git log:*)"
```

## The fixtures

| Fixture | Expected | Guards against |
|---|---|---|
| `clean-refactor` | ✅ no findings | Inventing findings on a clean diff |
| `style-only` | ✅ no findings | Reporting nits on a diff that invites them |
| `api-boundary` | ✅ no findings | Flagging a missing nil guard across an unseen API contract |
| `trivial-log-label` | 🟧 one MEDIUM | Trivia reaching HIGH and blocking the PR |
| `pagination-off-by-one` | 🚫 one HIGH | A real bug going unreported after tightening |
| `sql-injection` | 🚫 one CRITICAL | CRITICAL becoming unreachable after tightening |

Three expect silence, three expect a specific severity. That balance is the point: every
change in this repo so far has pushed toward reporting less, and the bottom three are
what catch an overcorrection. A run where all three "no findings" fixtures pass and
`pagination-off-by-one` returns nothing is a worse outcome than the noise it replaced.

## Adding one

A directory with `base/`, `head/`, and an `expected.md` covering:

- **What the diff does** — factually, no framing.
- **Expected result** — severity per finding and the verdict.
- **What this fixture is testing** — the specific failure mode. If you cannot name one,
  the fixture is not earning its place.
- **Fails if** — both directions. Over-reporting *and* under-reporting.
- **Known bait** — the plausible-looking non-findings you deliberately planted.

Keep them small. Every one here is under 30 lines of code, because a fixture you cannot
hold in your head is a fixture you cannot judge the review against.

## What these do not test

Anything about the model. The model is deliberately unpinned (see the 1.2.0 changelog
notes), so a result here is one sample from a moving target. A fixture regression tells
you something changed; it does not tell you whether the prompt or the model changed it.
