# style-only

## What the diff does

Adds filtering to `Importer#run`: rows are kept only when age is 18 or over and the name
is non-blank. Written as an accumulator with nested conditionals and single-letter
variables, and `normalise` gains an `adult: true` key.

## Expected result

**No findings. Verdict: ✅ Ship.**

## What this fixture is testing

Nit reporting on a diff that genuinely invites it. Unlike `clean-refactor`, this code is
actually ugly, so the reviewer has real material to be pulled toward — and every bit of
it is LOW.

The behaviour is correct and self-consistent: the filter matches the new `adult: true`
key, `to_i` on a missing age yields 0 which fails the check, and `to_s.strip` on nil
yields an empty string which also fails. Nothing here misbehaves.

## Known bait

- `r` and `x` as names. Naming preference, LOW.
- Nested `if`s that could be one condition or a `select`. Style, LOW.
- `each` with an accumulator where `select`/`map` would do. Style, LOW.
- The magic number `18`. A named constant would read better; not a defect.
- `adult: true` hardcoded rather than derived. It is only reachable when the age check
  passed, so it cannot be wrong. Tempting to flag as fragile — but state a trigger for
  it and you cannot, which makes it LOW.

## Fails if

Anything is reported at MEDIUM or above, or nits are appended as a note or a "minor
observations" list.

## Note

`adult: true` is the interesting one. It is the closest thing here to a real finding —
a reviewer can construct a story about a future refactor moving the check and leaving
the flag behind. That story has no trigger in this diff, so it is LOW. If the reviewer
reports one thing on this fixture, expect it to be that.
