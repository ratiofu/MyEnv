# --- Kiro ---

# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && source "$(kiro --locate-shell-integration-path zsh)"

# --- Path ---

# Source custom paths if available
CUSTOM_PATHS="$HOME/.zsh_paths"
[[ -f "$CUSTOM_PATHS" ]] && source "$CUSTOM_PATHS"

# --- Command History ---

export HISTFILE=~/.zsh_history
export HISTFILESIZE=10000000
export HISTSIZE=100000
export SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS     # on add: remove older duplicate
setopt HIST_SAVE_NO_DUPS        # on save: skip duplicates
setopt HIST_EXPIRE_DUPS_FIRST   # when trimming, drop duplicates first
setopt INC_APPEND_HISTORY       # write new cmds immediately
setopt SHARE_HISTORY            # share across sessions
setopt HISTIGNORESPACE          # ignore commands starting with space

# Up/Down = search history beginning with what's typed
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow


# --- Prompt Substitution ---

setopt prompt_subst
autoload -Uz colors vcs_info; colors   # colors + vcs_info module

# set misc to a single dot if repo is dirty (staged, unstaged, or untracked)
+vi-git-untracked() {
  local dirty
  git rev-parse --is-inside-work-tree &>/dev/null || return
  git diff --cached --quiet --ignore-submodules -- || dirty=1      # staged
  git diff --quiet --ignore-submodules -- || dirty=1               # unstaged
  git ls-files --others --exclude-standard | grep -q . && dirty=1  # untracked
  if [[ -n $dirty ]]; then
    # shellcheck disable=SC2154
    # shellcheck disable=SC2034
    hook_com[misc]=' ●' # one dot total
  fi
}

# configure vcs_info for Git only
zstyle ':vcs_info:*' enable git                # enable git support
zstyle ':vcs_info:git*' check-for-changes true # detect modified state
# use %m only; blank out %c/%u, use a single ● do signal any changes
zstyle ':vcs_info:git*' stagedstr ''          # was '●'
zstyle ':vcs_info:git*' unstagedstr ''        # was '●'
zstyle ':vcs_info:git*' formats '%F{45} %b%f%F{yellow}%m%f'
zstyle ':vcs_info:git*' actionformats '%F{45} %b|%a%f%F{yellow}%m%f'
zstyle ':vcs_info:git*:*' hooks git-untracked

# refresh vcs_info before each prompt
precmd() {
  vcs_info
}

# custom directory display
prompt_dir_compact() {
  local full_path=$PWD
  [[ $full_path == "/" ]] && {
    print -r -- "/"
    return
  }
  [[ $full_path == "$HOME" ]] && {
    print -r -- "~"
    return
  }

  local current_dir=${full_path:t}
  local parent_path=${full_path:h}
  [[ $parent_path == "/" ]] && {
    print -r -- "/$current_dir"
    return
  }

  local parent_dir=${parent_path:t}
  local grandparent_path=${parent_path:h}
  [[ $grandparent_path == "/" ]] && {
    print -r -- "/$parent_dir/$current_dir"
    return
  }
  [[ $parent_path == "$HOME" ]] && {
    # shellcheck disable=SC2088
    # using `~` on purpose
    print -r -- "~/$current_dir"
    return
  }
  [[ $grandparent_path == "$HOME" ]] && {
    # shellcheck disable=SC2088
    # using `~` on purpose
    print -r -- "~/$parent_dir/$current_dir"
    return
  }

  print -r -- "…/$parent_dir/$current_dir"
}

# showing venv activation
venv_tag() {
  [[ -n "$VIRTUAL_ENV" ]] && print -n "%F{130}($(basename "$VIRTUAL_ENV"))%f "
}

# Prompt: [venv] [git-info] current-directory %; expansion omitted on purpose
# shellcheck disable=SC2016
export PROMPT='$(venv_tag)${vcs_info_msg_0_} %F{13}$(prompt_dir_compact)%f %# '


# --- brew and brew-managed Ruby ---

if type brew &>/dev/null
then
  export PATH="/opt/homebrew/bin:$PATH"
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  RUBY_PATH=$(brew --prefix ruby)
  if [[ -d "$RUBY_PATH" ]]; then
    export PATH="$RUBY_PATH/bin:$PATH"
  fi
fi

# --- nvm (lazy loading) ---

export NVM_DIR="$HOME/.nvm"

# nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# --- pnpm ---

export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- Prompt Completion ---

autoload -Uz compinit
compinit

# Only load pnpm completion if pnpm is available
command -v pnpm &>/dev/null && eval "$(pnpm completion zsh)"


# --- direnv ---

[[ -n "$(command -v direnv)" ]] && eval "$(direnv hook zsh)"

# --- Shortcuts ---

# Clear merged branches that are gone at the remote origin
clrb() {
  local tempfile
  tempfile=$(mktemp /tmp/merged-branches-XXXXXX)
  git branch -vv | awk '/: gone]/{print $1}' > "${tempfile}"
  "${EDITOR:-vi}" "${tempfile}"
  xargs git branch -df < "${tempfile}"
  rm -f "${tempfile}"
}

# --- Aliases ---

alias l='ls -halt'
alias gts='git status'
alias gti='git commit -m'
alias gta='git add -A'
alias gtu='git remote prune origin && git pull --all'
alias gto='git checkout'

# --- local binaries ---

[[ -s "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
