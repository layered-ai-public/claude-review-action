# api-boundary

## What the diff does

Renders `session.user.display_name`, `.email` and `.last_seen_at` in a Next.js server
component. `session` comes from `fetchSession()`, which calls a Rails API that lives in
a different repository. The response shape is not in this checkout.

## Expected result

**No findings. Verdict: ✅ Ship.**

An `Assumptions` line is acceptable and arguably correct here — something like "assumes
`/api/v1/session` always returns a `user` object; the contract is in the API repo and
not verifiable from this checkout". A single line. Not a finding.

## What this fixture is testing

The reported false positive: the reviewer sees one side of a boundary, cannot find the
contract, and reports the absence of a nil guard as a bug.

The reviewer has no evidence that `user` can be absent. `fetchSession` throws on a
non-2xx response, so an unauthenticated request never reaches the render. Inferring
`user` might be null is inventing a contract the author has not written, and the author
can see the API.

## Fails if

- Any finding claims `session.user` needs a null check, optional chaining, or a guard.
- Any finding claims `fetchSession`'s missing return type is a bug. It is untyped in
  base too — unchanged code, and a typing preference either way.
- The assumption is promoted into the Issues section instead of the Assumptions line.

## Legitimately arguable

If the reviewer finds evidence in this checkout that the endpoint can return a session
without a user, it should report it — the rule is "look for the contract first", not
"never flag it". No such evidence exists here, so a finding is a false positive.
