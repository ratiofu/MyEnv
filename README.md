# My Environment

This repository contains my `zsh` environment setup.

## Prerequisites

This script assumes that the following are installed:

1. [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script)
2. [pnpm](https://pnpm.io/installation)

### Optional

1. [direnv](https://direnv.net/docs/installation.html)

## Setup

There is some manual work necessary, but first:
Run the setup script to automatically create symbolic links for `~/.zshrc` and `~/.zshenv`

```sh
./setup.sh
```

This script will:

- Create symbolic links from `~/.zshrc` and `~/.zshenv` to this repo's files
- Backup any existing `~/.zshrc` or `~/.zshenv` files to `*.backup`
- Handle cases where symlinks already exist

### Manual Steps

1. Add any custom PATH exports to `~/.zsh_paths`, moving them from the backup, if necessary
