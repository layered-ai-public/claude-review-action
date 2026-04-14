#!/bin/sh
# Install claude-review-action commands globally for Claude Code.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/layered-ai-public/claude-review-action/main/install-commands.sh | sh

set -e

# Where the commands will be installed
DEST="$HOME/.claude/commands"
REPO="layered-ai-public/claude-review-action"
COMMANDS_PATH="commands"
API="https://api.github.com/repos/$REPO/git/trees/main?recursive=1"
RAW="https://raw.githubusercontent.com/$REPO/main"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Installing claude-review-action commands..."

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

# Sanity check: code-review.md must be present for a valid install
if [ ! -f "$TMP/code-review.md" ]; then
  echo "Error: failed to download command files" >&2
  exit 1
fi

# Replace any existing install and move the new one into place
rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
mv "$TMP" "$DEST"

echo "Installed claude-review-action commands to $DEST"
echo "You can now use the /code-review and /code-review-and-fix commands in Claude Code."
