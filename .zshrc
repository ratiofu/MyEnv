[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Bigger, de-duped history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias l="ls -halt"
alias gts="git status"
alias gti="git commit -m"
alias gta="git add -A"

# --- Enable prompt substitution and load helpers ---
setopt prompt_subst
autoload -Uz colors vcs_info; colors   # colors + vcs_info module
autoload -U up-line-or-beginning-search down-line-or-beginning-search # cursor key history search

setopt HIST_IGNORE_ALL_DUPS     # on add: remove older duplicate
setopt HIST_SAVE_NO_DUPS        # on save: skip duplicates
setopt HIST_EXPIRE_DUPS_FIRST   # when trimming, drop dups first
setopt INC_APPEND_HISTORY       # write new cmds immediately
setopt SHARE_HISTORY            # share across sessions

# Up/Down = search history beginning with what's typed
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow

# --- Configure vcs_info for Git only ---
zstyle ':vcs_info:*' enable git                # enable git support
zstyle ':vcs_info:git*' check-for-changes true # detect modified state
# use %m only; blank out %c/%u
zstyle ':vcs_info:git*' stagedstr ''          # was '●'
zstyle ':vcs_info:git*' unstagedstr ''        # was '●'
zstyle ':vcs_info:git*' formats '%F{45} %b%f%F{yellow}%m%f'
zstyle ':vcs_info:git*' actionformats '%F{45} %b|%a%f%F{yellow}%m%f'

# hook: set misc to a single dot if repo is dirty (staged, unstaged, or untracked)
+vi-git-untracked() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  dirty=
  git diff --cached --quiet --ignore-submodules -- || dirty=1   # staged
  git diff --quiet --ignore-submodules -- || dirty=1            # unstaged
  git ls-files --others --exclude-standard | grep -q . && dirty=1  # untracked
  [[ -n $dirty ]] && hook_com[misc]=' ●' || true                 # one dot total
}

# --- Refresh vcs_info before each prompt ---
precmd() { vcs_info }

# --- custom directory display ---
prompt_dir_compact() {
  local full_path=$PWD
  [[ $full_path == "/"   ]] && { print -r -- "/"; return }
  [[ $full_path == $HOME ]] && { print -r -- "~"; return }

  local current_dir=${full_path:t}
  local parent_path=${full_path:h}
  [[ $parent_path == "/" ]] && { print -r -- "/$current_dir"; return }

  local parent_dir=${parent_path:t}
  local grandparent_path=${parent_path:h}
  [[ $grandparent_path == "/"   ]] && { print -r -- "/$parent_dir/$current_dir"; return }
  [[ $parent_path == $HOME      ]] && { print -r -- "~/$current_dir"; return }
  [[ $grandparent_path == $HOME ]] && { print -r -- "~/$parent_dir/$current_dir"; return }

  print -r -- "…/$parent_dir/$current_dir"
}

# --- showing venv ---
venv_tag() { [[ -n "$VIRTUAL_ENV" ]] && print -n "%F{130}($(basename "$VIRTUAL_ENV"))%f " }

# --- Prompt: [git-info] current-directory %
PROMPT='$(venv_tag)${vcs_info_msg_0_} %F{13}$(prompt_dir_compact)%f %# '

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
source ~/.pnpm-completion.sh
# pnpm end

eval "$(direnv hook zsh)"
