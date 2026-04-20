# --- Custom Path ---
CUSTOM_PATHS="$HOME/.zsh_paths"
[[ -f "$CUSTOM_PATHS" ]] && source "$CUSTOM_PATHS"

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# --- pnpm ---
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- brew and brew-managed Ruby ---
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if type brew &>/dev/null; then
  RUBY_PATH=$(brew --prefix ruby 2>/dev/null)
  if [[ -d "$RUBY_PATH" ]]; then
    export PATH="$RUBY_PATH/bin:$PATH"
  fi
fi

# --- bun ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- local binaries ---
[[ -s "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
