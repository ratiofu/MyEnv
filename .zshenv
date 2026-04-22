# --- Custom Path ---
CUSTOM_PATHS="$HOME/.zsh_paths"
[[ -f "$CUSTOM_PATHS" ]] && source "$CUSTOM_PATHS"

# --- Homebrew ---
typeset -U path PATH

RUBY_PATH="/opt/homebrew/opt/ruby/bin"
if [[ -d "$RUBY_PATH" ]]; then
  path=("$RUBY_PATH" $path)
fi

if [[ -d /opt/homebrew/bin ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
fi

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# --- pnpm ---
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- bun ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- local binaries ---
[[ -s "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
