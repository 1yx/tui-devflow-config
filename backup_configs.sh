#!/bin/bash

# TUI Dev OS Configuration Backup Script
# This script backs up user-level configuration files for tools used in this repo.
# It appends .bak to the original filename and DOES NOT delete original files.

# Define configuration paths to check
CONFIG_PATHS=(
    "$HOME/.config/ghostty"
    "$HOME/Library/Application Support/com.mitchellh.ghostty"
    "$HOME/.config/fish"
    "$HOME/.config/helix"
    "$HOME/.config/yazi"
    "$HOME/.config/lazygit"
    "$HOME/Library/Application Support/lazygit"
    "$HOME/.config/starship.toml"
    "$HOME/.gitconfig"
    "$HOME/.config/git/config"
    "$HOME/.config/git/ignore"
    "$HOME/.config/worktrunk"
    "$HOME/.claude"
    "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
)

echo "Starting configuration backup..."

for path in "${CONFIG_PATHS[@]}"; do
    if [ -e "$path" ]; then
        # Check if backup already exists
        if [ -e "${path}.bak" ]; then
            echo "⚠️  Skipping: ${path}.bak already exists."
        else
            # Perform backup (recursive for directories, simple for files)
            cp -RL "$path" "${path}.bak"
            echo "✅ Backed up: $path -> ${path}.bak"
        fi
    else
        echo "ℹ️  Not found: $path (Skipping)"
    fi
done

echo "Backup process complete. Please review the .bak files in your system."
