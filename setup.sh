#!/bin/bash

# Setup script for MyEnv zsh configuration
# Creates symbolic link from this repo's .zshrc to ~/.zshrc

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="${SCRIPT_DIR}/.zshrc"
ZSHRC_TARGET="${HOME}/.zshrc"

echo "Setting up zsh configuration..."

# Check if source file exists
if [[ ! -f "$ZSHRC_SOURCE" ]]; then
    echo "Error: .zshrc not found in $SCRIPT_DIR"
    exit 1
fi

# Backup existing .zshrc if it exists and is not already a symlink to our file
if [[ -f "$ZSHRC_TARGET" ]]; then
    if [[ -L "$ZSHRC_TARGET" ]]; then
        CURRENT_TARGET=$(readlink "$ZSHRC_TARGET")
        if [[ "$CURRENT_TARGET" == "$ZSHRC_SOURCE" ]]; then
            echo "✓ Symbolic link already exists and points to the correct file"
            exit 0
        else
            echo "Removing existing symlink that points to: $CURRENT_TARGET"
            rm "$ZSHRC_TARGET"
        fi
    else
        echo "Backing up existing .zshrc to ~/.zshrc.backup"
        mv "$ZSHRC_TARGET" "${ZSHRC_TARGET}.backup"
    fi
fi

# Create the symbolic link
echo "Creating symbolic link: $ZSHRC_TARGET -> $ZSHRC_SOURCE"
ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

echo "✓ Setup complete! Your zsh configuration is now linked."
echo "  Source: $ZSHRC_SOURCE"
echo "  Target: $ZSHRC_TARGET"
echo ""
echo "Restart your terminal or run 'source ~/.zshrc' to apply changes."