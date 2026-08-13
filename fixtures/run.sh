#!/usr/bin/env bash
#
# Build a throwaway git repo for a review fixture.
#
#   ./fixtures/run.sh trivial-log-label
#
# Commits base/ as `main`, then head/ as a branch, so `git diff main...HEAD` inside the
# temp repo produces exactly the diff under review. Prints the path to cd into.
#
set -euo pipefail

FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "usage: $(basename "$0") <fixture>"
  echo
  echo "available fixtures:"
  for dir in "$FIXTURES_DIR"/*/; do
    [ -d "${dir}base" ] || continue
    echo "  $(basename "$dir")"
  done
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

FIXTURE="$1"
SRC="$FIXTURES_DIR/$FIXTURE"

if [ ! -d "$SRC/base" ] || [ ! -d "$SRC/head" ]; then
  echo "error: no fixture named '$FIXTURE' (needs base/ and head/)" >&2
  echo >&2
  usage >&2
  exit 1
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/review-fixture-$FIXTURE.XXXXXX")"

git init -q -b main "$WORK"
git -C "$WORK" config user.email fixtures@example.com
git -C "$WORK" config user.name "Review Fixtures"

# Base commit.
cp -R "$SRC/base/." "$WORK/"
git -C "$WORK" add -A
git -C "$WORK" commit -q -m "Base state for $FIXTURE fixture"

# Head commit: wipe the tracked tree first so deletions in head/ are represented.
git -C "$WORK" rm -rq --cached .
find "$WORK" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$SRC/head/." "$WORK/"
git -C "$WORK" checkout -q -b fixture-change
git -C "$WORK" add -A
git -C "$WORK" commit -q -m "Change under review in $FIXTURE fixture"

CHANGED=$(git -C "$WORK" diff --shortstat main...HEAD)

cat <<EOF
Fixture:  $FIXTURE
Repo:     $WORK
Diff:     ${CHANGED:-(no changes — check base/ and head/ differ)}

Run the review:

  cd "$WORK" && claude

then invoke /code-review inside that session.

Expected result: $SRC/expected.md
(read it AFTER the review, so the expectation does not prime the reviewer)
EOF
