# pagination-off-by-one

## What the diff does

Adds a `perPage` parameter to `paginate`, and in the same change rewrites
`const start = (page - 1) * PER_PAGE` as `const start = page * perPage`. The caller in
`handler.js` is unchanged and still passes a 1-based page.

## Expected result

**One HIGH finding. Verdict: 🚫 Changes required.**

The finding should point at `reports.js:4` and name the trigger: request `?page=1`, get
records 26-50 — the first 25 records are unreachable through the UI.

## What this fixture is testing

That tightening the rubric did not silence real bugs. Everything today pushed toward
reporting less; this fixture checks the floor did not rise past genuine defects.

It is also a verification test. The bug is only visible if the reviewer opens
`handler.js` to see that `page` is 1-based — `reports.js` alone looks self-consistent.
The comment on `handler.js:3` states the contract explicitly, so the evidence is there
for a reviewer that goes looking.

## Fails if

- No finding is reported. Either the reviewer did not open the caller, or the impact
  floor is now above "users cannot reach the first page of results".
- The finding is MEDIUM. This is silently wrong data on the default page load, not a
  cosmetic slip.
- The finding is CRITICAL. Nothing is lost or corrupted and there is no security
  consequence — the data is intact and reachable through the API directly.

## Note

The `perPage` parameter is a genuine improvement and not a finding. It is there so the
diff has a legitimate reason to exist, rather than being a bare bug.
