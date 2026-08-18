# --- Kiro ---

# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && source "$(kiro --locate-shell-integration-path zsh)"


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

# showing OrbStack status
orbstack_tag() {
  [[ "$PWD" == *"/OrbStack"* ]] && print -n "📦 "
}

# Prompt: [orbstack] [venv] [git-info] current-directory %; expansion omitted on purpose
# shellcheck disable=SC2016
export PROMPT='$(orbstack_tag)$(venv_tag)${vcs_info_msg_0_} %F{13}$(prompt_dir_compact)%f %# '

# --- brew completion ---
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
fi


# --- Prompt Completion ---
autoload -Uz compinit
compinit

# --- pnpm completion ---
command -v pnpm &>/dev/null && eval "$(pnpm completion zsh)"

# --- direnv ---
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# --- Shortcuts ---

# Clear merged branches that are gone at the remote origin
clrb() {
  local b base c head
  # currently checked-out branch
  head=$(git symbolic-ref --short HEAD)

  for b in $(git for-each-ref --format='%(refname:short)' refs/heads); do
    # never delete current or protected branches
    [[ "$b" == "$head" || "$b" == main || "$b" == master || "$b" == develop ]] && continue
    # skip branches with remotes
    git rev-parse --abbrev-ref "$b@{upstream}" >/dev/null 2>&1 && continue

    base=""
    # scan recent commits for a squash-merge equivalent
    for c in $(git log -n 100 --pretty=%H); do
      # identical trees → found merge commit
      git diff --quiet "$c" "$b" && { base="$c"; break; }
    done
    [[ -z "$base" ]] && base="$head" # fallback: compare against current branch tip

    if git diff --quiet "$base" "$b"; then       # no file-content differences
      git branch -D "$b" && echo "deleted $b"
    else
      printf "delete %s? [y/N] " "$b"
      read -r ans
      [[ "$ans" =~ ^[Yy] ]] && git branch -D "$b" && echo "deleted $b"
    fi
  done
}

# --- Tools ---

# Wrapper for git worktree add to handle branch naming and validation
git_worktree_add_wrapper() {
  local prefix=""
  local base_branch=""
  local stay=0
  local branch_name=""

  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p)
        prefix="$2"
        shift 2
        ;;
      -m)
        base_branch="master"
        shift
        ;;
      -s)
        stay=1
        shift
        ;;
      -*)
        echo "Error: Unknown option $1"
        return 1
        ;;
      *)
        if [[ -z "$branch_name" ]]; then
          branch_name="$1"
        else
          echo "Error: Too many arguments: $1"
          return 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$branch_name" ]]; then
    echo "Error: Branch name is required."
    return 1
  fi

  local full_name="${prefix}${branch_name}"
  local target_dir="../${full_name}"

  if git rev-parse --verify "${full_name}" >/dev/null 2>&1; then
    echo "Branch '${full_name}' already exists. Adding worktree for existing branch..."
    git worktree add "${target_dir}" "${full_name}" || return 1
  else
    if [[ -n "$base_branch" ]]; then
      echo "Creating new branch '${full_name}' from ${base_branch} and adding worktree..."
      git worktree add "${target_dir}" -b "${full_name}" "${base_branch}" || return 1
    else
      echo "Creating new branch '${full_name}' and adding worktree..."
      git worktree add "${target_dir}" -b "${full_name}" || return 1
    fi
  fi

  if [[ $stay -eq 0 ]]; then
    cd "${target_dir}" || return 1
  fi
}

# Search for a term in files added or changed relative to a branch
_gf_impl() {
  local filter="$1"
  local branch="$2"
  local term="$3"

  if [[ -z "$branch" ]]; then
    print -P "%F{red}Error: branch name was not supplied%f"
    return 1
  fi

  git diff -z --name-only --diff-filter="$filter" "$(git merge-base HEAD "$branch")" HEAD | xargs -0 rg "$term"
}

# Search in NEW files relative to branch
gfnew() { _gf_impl "A" "$@"; }

# Search in ALL changed files relative to branch
gfchange() { _gf_impl "ACMR" "$@"; }

# --- Aliases ---
alias l='ls -halt'
alias gts='git status'
alias gti='git commit -m'
alias gta='git add -A'
alias gtu='git remote prune origin && git pull --all'
alias gto='git checkout'
alias gbd='git branch -D'
alias loc='cloc --exclude-dir=node_modules,generated,build,build-cache,.idea,.gradle,.ci-root-home,storybook-static .'
alias bzt='bazel test --test_output=errors --nocache_test_results'
alias bba='bazel build //...'
alias gwa='git_worktree_add_wrapper'
alias gwatj='git_worktree_add_wrapper -p dev-tj-'
alias gwl='git worktree list'
alias gwd='git worktree remove'

q() {
  claude -p --model haiku "respond to the following prompt with a single line output: $@"
}

# --- Custom Aliases ---
CUSTOM_ALIASES="$HOME/.zsh_aliases"
[[ -f "$CUSTOM_ALIASES" ]] && source "$CUSTOM_ALIASES"


# --- ngrok shell completion ---
command -v ngrok &>/dev/null && eval "$(ngrok completion)"

# --- bun completions ---
[ -s "/Users/tj/.bun/_bun" ] && source "/Users/tj/.bun/_bun"

# --- Environment Variables ---
CUSTOM_ENVS="$HOME/.zsh_envs"
[[ -f "$CUSTOM_ENVS" ]] && source "$CUSTOM_ENVS"
