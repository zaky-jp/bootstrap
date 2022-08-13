#!/usr/bin/env zsh


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

# ls
local _ls_args="-aAF"
local _ls_colour
# colourize
case "${RUNOS}" in;
  'darwin') _ls_colour="-G";;
  *) _ls_colour="--color";; # assume gnu-ls
esac
alias ls="ls ${_ls_args} ${_ls_colour}"
alias lsl="ls -l ${_ls_args} ${_ls_colour}"

# brew
if [[ "$RUNOS" == 'darwin' ]]; then
  # execute command as _brew user
  alias brew='sudo -i -u _brew -- brew'
fi

# completion
autoload -Uz compinit && compinit
[[ ${ZDOTDIR}/.zcompdump.zwc -nt ${ZDOTDIR}/.zcompdump ]] || zcompile -R -- ${ZDOTDIR}/.zcompdump{.zwc,}

# prepare zplug
export ZPLUG_HOME="${XDG_DATA_HOME}/zsh/zplug"
if [[ -d "${ZPLUG_HOME}" ]]; then
  export ZPLUG_CACHE_DIR="${XDG_CACHE_HOME}/zsh/zplug"
  source "${ZPLUG_HOME}/init.zsh"

  # list plugins
  zplug "zplug/zplug", depth:1, hook-build:"zplug --self-manage"
  zplug "chrissicool/zsh-256color"
  zplug "zsh-users/zsh-syntax-highlighting", depth:1 # no need to worry about compinit zsh >5.8
  zplug "zsh-users/zsh-autosuggestions", depth:1 \
    && export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  zplug "plugins/shrink-path", from:oh-my-zsh, depth:1

  # make sure to install plugin
  zplug check || zplug install

  # create cache files if needed
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in \
    ${ZPLUG_REPOS}/**/*.zsh(.) \
    ${ZPLUG_REPOS}/zplug/zplug/autoload/**/^*.zwc(.); do
      [[ $f.zwc -nt $f ]] || zcompile -R -- $f.zwc $f
    done
  }

  zplug load
fi
