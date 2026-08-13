# clean-refactor

## What the diff does

Extracts `lineTotal`, `applyBulkDiscount` and `roundToPence` out of `cartTotal`, and
names the two discount constants. Behaviour is identical: same threshold, same rate,
same rounding, same order of operations.

## Expected result

**No findings. Verdict: ✅ Ship.**

## What this fixture is testing

Fussiness. There is nothing wrong here, so any finding is a false positive. This is
the fixture that fails when the reviewer feels obliged to say something.

## Known bait

- `reduce` replacing an explicit loop is a style change, not a finding.
- Three small functions where there was one is a design preference, not a finding.
- No test was added alongside the refactor. The reviewer cannot run tests and the
  diff adds no behaviour, so this is not a finding.
- `roundToPence` is GB-specific naming in code with no other locale handling. Naming
  opinion, LOW, discard.

## Fails if

The reviewer reports anything at MEDIUM or above, or appends nits as a note.
