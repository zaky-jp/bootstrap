#!/usr/bin/env zsh
# prompt
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
## Activate Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Activate zplug
if [[ -e "${PLAYGROUND_DIR}/shell/zplug.zsh" ]]; then
  source "${PLAYGROUND_DIR}/shell/zplug.zsh"
fi

# command history
export HISTFILE="${XDG_DATA_HOME}/zsh/histfile"
if [[ ! -w "${HISTFILE}" ]]; then
  mkdir -p "$(dirname ${HISTFILE})"
  touch "${HISTFILE}"
fi

if [[ -w "${HISTFILE}" ]]; then
  export HISTSIZE=1001
  export SAVEHIST=1000
  setopt APPEND_HISTORY # set by default
  setopt EXTENDED_HISTORY # include timestamp + duration
  setopt INC_APPEND_HISTORY_TIME # write history after the command is finished
  setopt HIST_FCNTL_LOCK # use OS-native filelock
  setopt HIST_EXPIRE_DUPS_FIRST # need $HISTSIZE > $SAVEHIST
  setopt HIST_IGNORE_DUPS # remove if the same commands are entered consecutively
  setopt HIST_IGNORE_SPACE # remove first character if whitespace
  setopt HIST_LEX_WORDS # shell-like whitespace handling
  setopt HIST_NO_STORE # supress storing history command itself
  setopt HIST_REDUCE_BLANKS
  setopt HIST_VERIFY # safe paste; do not execute the command directly
  setopt HIST_FIND_NO_DUPS
fi

# alias
if [[ -e "${PLAYGROUND_DIR}/shell/alias.zsh" ]]; then
  source "${PLAYGROUND_DIR}/shell/alias.zsh"
fi

# completion
if (( $+commands[brew] )); then
  ## if brew directory is owned by different user, never able to supress security warnings
  ## thus rsyncing to user-owned directory
  rsync -Lrq --delete --chmod=ugo=rwX "${HOMEBREW_PREFIX}/share/zsh/site-functions" "${XDG_DATA_HOME}/zsh"
  FPATH="${XDG_DATA_HOME}/zsh/site-functions:${FPATH}"
fi
typeset -gU fpath FPATH

autoload -Uz compinit && compinit -u
[[ ${ZDOTDIR}/.zcompdump.zwc -nt ${ZDOTDIR}/.zcompdump ]] || zcompile -R -- ${ZDOTDIR}/.zcompdump{.zwc,}

# functions
if [[ -d "${XDG_DATA_HOME}/zsh/functions" ]]; then
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in ${XDG_DATA_HOME}/zsh/functions/*(.); do
    source $f
  done
}
fi

# load zplug
[[ -d "${ZPLUG_HOME}" ]] && zplug load

# load p10k config
[[ -r "${ZDOTDIR}/.p10k.zsh" ]] && source "${ZDOTDIR}/.p10k.zsh"
