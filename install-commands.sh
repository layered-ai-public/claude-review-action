#!/bin/sh
# Install claude-review-action commands globally for Claude Code.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/layered-ai-public/claude-review-action/main/install-commands.sh | sh

set -e

DEST="$HOME/.claude/commands"
REPO="layered-ai-public/claude-review-action"
COMMANDS_PATH="commands"
API="https://api.github.com/repos/$REPO/git/trees/main?recursive=1"
RAW="https://raw.githubusercontent.com/$REPO/main"

echo "Installing claude-review-action commands..."

rm -rf "$DEST"

curl -fsSL "$API" | grep "\"path\": \"$COMMANDS_PATH/" | while read -r line; do
  file=$(echo "$line" | sed "s|.*\"path\": \"$COMMANDS_PATH/||" | sed 's/".*//')
  mkdir -p "$DEST/$(dirname "$file")"
  curl -fsSL "$RAW/$COMMANDS_PATH/$file" -o "$DEST/$file"
done

echo "Installed to $DEST"
