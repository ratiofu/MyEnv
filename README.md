# My Environment

This repository contains my `zsh` environment setup.

## Prequisits

This script assumes that the following are installed:

1. [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script)
2. [pnpm](https://pnpm.io/installation)

## Setup

Run the setup script to automatically create the symbolic link for `~/.zshrc`

```sh
./setup.sh
```

This script will:
- Create a symbolic link from `~/.zshrc` to this repo's `.zshrc`
- Backup any existing `~/.zshrc` file to `~/.zshrc.backup`
- Handle cases where a symlink already exists
