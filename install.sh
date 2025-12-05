#!/bin/bash
# install.sh - Symlink Claude Code configuration to ~/.claude/
#
# Run this after cloning the repo to set up your Claude Code CLI config.
# Symlinks ensure changes are tracked in git and visible across machines.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code configuration from: $SCRIPT_DIR"
echo ""

# Create ~/.claude if it doesn't exist
mkdir -p ~/.claude

# Items to symlink (safe, no secrets)
ITEMS="CLAUDE.md skills settings.local.json"

for item in $ITEMS; do
    target="$HOME/.claude/$item"
    source="$SCRIPT_DIR/$item"

    # Check source exists
    if [ ! -e "$source" ]; then
        echo "SKIP: $item (not found in repo)"
        continue
    fi

    # Handle existing file/directory
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            # Already a symlink - check if it points to us
            current_link=$(readlink "$target")
            if [ "$current_link" = "$source" ]; then
                echo "OK:   $item (already linked)"
                continue
            else
                echo "UPDATE: $item (was linked to $current_link)"
                rm "$target"
            fi
        else
            # Real file/directory - back it up
            backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
            echo "BACKUP: $item -> $backup"
            mv "$target" "$backup"
        fi
    fi

    # Create symlink
    ln -s "$source" "$target"
    echo "LINK: $item -> $source"
done

echo ""
echo "Done. Your ~/.claude/ now symlinks to this repo."
echo ""
echo "To verify:"
echo "  ls -la ~/.claude/CLAUDE.md"
echo "  ls -la ~/.claude/skills"
echo ""
echo "Changes you make will be tracked in git. Remember to commit and push."
