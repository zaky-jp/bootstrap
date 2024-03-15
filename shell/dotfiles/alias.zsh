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
  'macos') _ls_colour="-G";;
  *) _ls_colour="--color";; # assume gnu-ls
esac
alias ls="ls ${_ls_args} ${_ls_colour}"
alias lsl="ls -l ${_ls_args} ${_ls_colour}"

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



## container
if (( $+commands[lima])); then
  alias nerdctl="${commands[lima]} nerdctl"
 # alias lxc="${commands[lima]} sudo lxc" # should be using lxc locally with lxc remote set
  alias lxd="${commands[lima]} sudo lxd"
fi
