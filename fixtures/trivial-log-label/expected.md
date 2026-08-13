# trivial-log-label

## What the diff does

Adds a log line to `deleteOrder` that reads `'order created'` — copy-pasted from
`createOrder` and not reworded.

## Expected result

**Exactly one MEDIUM finding. Verdict: 🟧 Ship (medium findings to address).**

The finding should point at `orders.js:11` and name the trigger: call `deleteOrder`,
get a log line claiming an order was created.

## What this fixture is testing

The impact floor on HIGH — the regression fixed in 628fbf8.

The trigger here is as nameable and reachable as it gets: call the function, get the
wrong log line. Under a rubric where HIGH means only "nameable trigger produces
incorrect behaviour", this lands at HIGH and blocks the PR over a copy-paste slip.
It should be MEDIUM: real, worth fixing, not worth blocking.

## Fails if

- The finding is reported as HIGH or CRITICAL, or the verdict is 🚫 Changes required.
  That is the impact floor gone.
- No finding is reported at all. This is a genuine defect and dropping it means the
  floor was set too high. Log output is how someone debugs a deletion that went
  wrong, and this line will actively mislead them.

## Note

This fixture cuts both ways on purpose. It is the one to re-run after any change to
the severity bands, because it sits exactly on the MEDIUM/HIGH line.
