# My Environment

This repository contains my `zsh` environment setup.

## Setup

Run the setup script to automatically create the symbolic link for `~/.zshrc`

```sh
./setup.sh
```

This script will:
- Create a symbolic link from `~/.zshrc` to this repo's `.zshrc`
- Backup any existing `~/.zshrc` file to `~/.zshrc.backup`
- Handle cases where a symlink already exists
