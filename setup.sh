#!/bin/bash

# Setup script for MyEnv zsh configuration
# Creates symbolic links for .zshrc and .zshenv

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_symlink() {
    local filename="$1"
    local source_file="${SCRIPT_DIR}/${filename}"
    local target_file="${HOME}/${filename}"

    echo "Setting up ${filename}..."

    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        echo "Error: ${filename} not found in $SCRIPT_DIR"
        exit 1
    fi

    # Check if target exists
    if [[ -e "$target_file" || -L "$target_file" ]]; then
        if [[ -L "$target_file" ]]; then
            local current_target
            current_target=$(readlink "$target_file")
            if [[ "$current_target" == "$source_file" ]]; then
                echo "✓ Symbolic link for ${filename} already exists and points to the correct file"
                return 0
            else
                echo "Removing existing symlink for ${filename} that points to: $current_target"
                rm "$target_file"
            fi
        else
            echo "Backing up existing ${filename} to ${target_file}.backup"
            mv "$target_file" "${target_file}.backup"
        fi
    fi

    # Create the symbolic link
    echo "Creating symbolic link: $target_file -> $source_file"
    ln -s "$source_file" "$target_file"
    echo "✓ ${filename} linked successfully."
}

echo "Starting environment setup..."
echo ""

setup_symlink ".zshrc"
echo ""
setup_symlink ".zshenv"

echo ""
echo "✓ Setup complete! Your zsh configuration is now linked."
echo "Restart your terminal or run 'source ~/.zshenv && source ~/.zshrc' to apply changes."