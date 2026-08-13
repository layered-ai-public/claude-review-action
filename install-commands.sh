#!/bin/sh
# Install claude-review-action commands for Claude Code.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/layered-ai-public/claude-review-action/main/install-commands.sh | sh
#
# Run from a local checkout, this installs the commands from that working tree —
# useful for testing prompt changes on a branch before they are merged:
#
#   ./install-commands.sh            # local checkout if detected, else GitHub main
#   ./install-commands.sh --remote   # always GitHub main
#   ./install-commands.sh --local    # always this working tree, error if not a checkout

set -e

DEST="$HOME/.claude/commands"
REPO="layered-ai-public/claude-review-action"
COMMANDS_PATH="commands"
API="https://api.github.com/repos/$REPO/git/trees/main?recursive=1"
RAW="https://raw.githubusercontent.com/$REPO/main"

MODE=auto
for arg in "$@"; do
  case "$arg" in
    --local) MODE=local ;;
    --remote) MODE=remote ;;
    -h|--help)
      sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "error: unknown option '$arg' (try --help)" >&2
      exit 1
      ;;
  esac
done

# Directory this script lives in, when it was run as a file. Piped through sh
# there is no file to locate, so this stays empty and we install from GitHub.
# Deliberately based on the script's own path rather than the working directory,
# so `curl | sh` behaves the same wherever it is run from.
SCRIPT_DIR=""
case "$0" in
  sh | -sh | dash | -dash | bash | -bash | - | /dev/*) ;;
  *) [ -f "$0" ] && SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)" ;;
esac

# A checkout of THIS project, not just any directory with a commands/ folder.
is_local_checkout() {
  [ -n "$SCRIPT_DIR" ] || return 1
  [ -f "$SCRIPT_DIR/$COMMANDS_PATH/code-review.md" ] || return 1
  [ -f "$SCRIPT_DIR/action.yml" ] || return 1
  grep -q '^name: Claude Review Action' "$SCRIPT_DIR/action.yml" || return 1
}

if [ "$MODE" = local ] && ! is_local_checkout; then
  echo "error: --local given but this is not a claude-review-action checkout" >&2
  echo "       (expected $COMMANDS_PATH/code-review.md and action.yml next to this script)" >&2
  exit 1
fi

if [ "$MODE" = local ] || { [ "$MODE" = auto ] && is_local_checkout; }; then
  SRC="$SCRIPT_DIR/$COMMANDS_PATH"

  BRANCH=$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ -n "$BRANCH" ]; then
    echo "Installing commands from local checkout (branch: $BRANCH)..."
  else
    echo "Installing commands from local checkout..."
  fi

  # Installing an uncommitted prompt is usually the point when testing a change,
  # but say so — an unexpected local edit is otherwise invisible until a review
  # behaves oddly.
  if [ -n "$BRANCH" ] && ! git -C "$SCRIPT_DIR" diff --quiet -- "$COMMANDS_PATH" 2>/dev/null; then
    echo "note: $COMMANDS_PATH/ has uncommitted changes — installing them as they are"
  fi
else
  echo "Installing claude-review-action commands from $REPO (main)..."

  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  SRC="$TMP"

  # Fetch the repo's file tree from the GitHub API
  TREE="$TMP/tree.json"
  curl -fsSL "$API" -o "$TREE"

  # Extract command file paths from the tree (matching our commands directory)
  grep "\"path\": \"$COMMANDS_PATH/" "$TREE" > "$TMP/files.txt" || true

  # Download each file into the temp directory.
  # Uses file redirection (not a pipe) so the loop runs in the current shell,
  # ensuring set -e and exit 1 work correctly on download failure.
  while read -r line; do
    file=$(echo "$line" | sed "s|.*\"path\": \"$COMMANDS_PATH/||" | sed 's/".*//')
    mkdir -p "$TMP/$(dirname "$file")"
    curl -fsSL "$RAW/$COMMANDS_PATH/$file" -o "$TMP/$file" || { echo "Error: failed to download $file" >&2; exit 1; }
  done < "$TMP/files.txt"

  # Clean up intermediate files
  rm -f "$TMP/files.txt"
  rm -f "$TREE"
fi

# Sanity check: code-review.md must be present for a valid install
if [ ! -f "$SRC/code-review.md" ]; then
  echo "Error: no command files found to install" >&2
  exit 1
fi

# Copy the commands into the destination, overwriting only our files
mkdir -p "$DEST"
for f in "$SRC"/*.md; do
  [ -f "$f" ] && cp "$f" "$DEST/"
done

echo "Installed claude-review-action commands to $DEST"
echo "You can now use the /code-review and /code-review-and-fix commands in Claude Code."
