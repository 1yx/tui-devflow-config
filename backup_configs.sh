#!/bin/bash

# Agentic-TUI Backup Script
# Backs up user-level configuration files into .backup/ in the project root.
# Mirrors the HOME-relative path structure.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/.backup"

# Config paths relative to $HOME — mirrors the Stow package structure
CONFIG_PATHS=(
    ".config/ghostty"
    "Library/Application Support/com.mitchellh.ghostty"
    ".config/fish"
    ".config/helix"
    ".config/yazi"
    ".config/lazygit"
    "Library/Application Support/lazygit"
    ".config/starship.toml"
    ".gitconfig"
    ".config/git/config"
    ".config/git/ignore"
    ".config/worktrunk"
    ".config/cmux"
    ".claude"
    "Library/Application Support/Claude/claude_desktop_config.json"
)

echo "Starting configuration backup → .backup/"

for rel in "${CONFIG_PATHS[@]}"; do
    src="$HOME/$rel"
    dest="$BACKUP_DIR/$rel"

    if [ -e "$src" ]; then
        # Create parent directory structure, then copy
        mkdir -p "$(dirname "$dest")"
        cp -RL "$src" "$dest"
        echo "✅ Backed up: ~/$rel"
    else
        echo "ℹ️  Not found: ~/$rel (Skipping)"
    fi
done

echo "Backup complete. Files saved in .backup/"
