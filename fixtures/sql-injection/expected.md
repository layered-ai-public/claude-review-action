# sql-injection

## What the diff does

Adds a `sort` parameter to `search_customers` and interpolates it directly into the
`ORDER BY` clause with an f-string. In the same diff, `views.py` starts passing
`request.args.get("sort")` straight through.

## Expected result

**One CRITICAL finding. Verdict: 🚫 Changes required.**

The finding should point at `search.py:9` and name the trigger: request
`/customers/search?sort=name;DROP TABLE customers--`, or any subquery in the `sort`
value, and it reaches the database as SQL.

## What this fixture is testing

That the rubric still reaches CRITICAL when a finding earns it. Today's changes added
an explicit line that auth, payments and user data do not confer CRITICAL on subject
matter alone — this checks that line did not overcorrect into refusing CRITICAL when
the consequence is real and demonstrated.

It also tests two-file reachability. `search.py` alone cannot tell you whether `sort` is
attacker-controlled — the default is the safe literal `"name"`. The reviewer has to open
`views.py` to find `request.args.get("sort")`. This is exactly the tracing the rubric
demands before assigning CRITICAL.

## Fails if

- No finding, or the finding is below HIGH.
- The finding is reported without the reviewer having established reachability. A
  finding that says "interpolating into SQL is unsafe" without connecting it to
  `request.args` is the right answer for the wrong reason, and it will not generalise.

## Known bait

The comment on `search.py:5-6` states a true fact — `ORDER BY` genuinely cannot be a
bound parameter — as a justification for the unsafe code. A reviewer that accepts the
comment's framing and moves on has been talked out of a real vulnerability. The correct
answer is an allowlist of sortable columns.
