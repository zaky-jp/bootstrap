#!/usr/bin/env zsh
# prompt
## Activate Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# prepare zplug
export ZPLUG_HOME="${XDG_DATA_HOME}/zsh/zplug"
if [[ -d "${ZPLUG_HOME}" ]]; then
  export ZPLUG_CACHE_DIR="${XDG_CACHE_HOME}/zsh/zplug"
  source "${ZPLUG_HOME}/init.zsh"

  ## list plugins
  zplug "zplug/zplug", depth:1, hook-build:"zplug --self-manage"
  zplug "chrissicool/zsh-256color"
  zplug "zsh-users/zsh-syntax-highlighting", depth:1, defer:2
  zplug "zsh-users/zsh-autosuggestions", depth:1
  zplug "plugins/shrink-path", from:oh-my-zsh, depth:1
  zplug "zaky-jp/globalias-augmented", depth:1, use:'globalias.plugin.zsh'
  zplug "endaaman/lxd-completion-zsh", depth:1, if:"(( $+commands[lxc] ))"
  zplug "romkatv/powerlevel10k", as:theme, depth:1

  ## make sure to install plugin
  zplug check || zplug install

  ## create precompiled files if needed
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in \
    ${ZPLUG_REPOS}/**/*.zsh(.) \
    ${ZPLUG_REPOS}/zplug/zplug/autoload/**/^*.zwc(.); do
      [[ $f.zwc -nt $f ]] || zcompile -R -- $f.zwc $f
    done
  }
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
## rm
if (( $+commands[trash] )); then
  # TODO implement -R and other option switches
  alias rm="trash"
fi

## ls
local _ls_args="-aAF"
local _ls_colour
# colourize
case "${RUNOS}" in;
  'darwin') _ls_colour="-G";;
  *) _ls_colour="--color";; # assume gnu-ls
esac
alias ls="ls ${_ls_args} ${_ls_colour}"
alias lsl="ls -l ${_ls_args} ${_ls_colour}"

## brew
if [[ "$RUNOS" == 'darwin' ]]; then
  # execute command as _brew user
  alias brew='sudo -i -u _brew -- brew'
fi

## vim
if (( $+commands[vimr] )); then
  alias gv=vimr
fi
alias v="${EDITOR}"

## git
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git push"
alias gd="git diff"
alias gds="git diff --staged"

# prompt
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# completion
if (( $+commands[brew] )); then
  ## if brew directory is owned by different user, never able to supress security warnings
  ## thus rsyncing to user-owned directory
  rsync -Lrq --delete --chmod=ugo=rwX "$(command brew --prefix)/share/zsh/site-functions" "${XDG_DATA_HOME}/zsh"
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
