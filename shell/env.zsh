# define local functions
function append_path {
  export PATH="$*:${PATH}"
  typeset -gU PATH path
}

# declare RUNOS variable
case $OSTYPE in
  "linux-gnu")
    RUNOS="${(L)$(lsb_release --id --short)}" # convert to lowercase
    ;;
  "darwin"*)
    RUNOS="macos"
    ;;
  *)
    RUNOS="${OSTYPE}"
    ;;
esac
export RUNOS

# configure path
if [[ ${RUNOS} == "macos" ]]; then
  if [[ -e "/opt/homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -e "/usr/local/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi

  if [[ -v "HOMEBREW_PREFIX" ]]; then
    export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar";
    export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew";
    append_path "${HOMEBREW_PREFIX}/bin"
    append_path "${HOMEBREW_PREFIX}/sbin"
    #export MANPATH="${HOMEBREW_PREFIX}/share/man${MANPATH+:$MANPATH}:";
    #export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}";

    # program-specific
    # gcp sdk
    if [[ -d "${HOMEBREW_PREFIX}/share/google-cloud-sdk" ]]; then
      source "${HOMEBREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc"
    fi
  fi
fi

if [[ -d "${HOME}/.local/bin" ]]; then
  # systemd expects user binary in this directory
  append_path "${HOME}/.local/bin"
fi

# TODO: proper pip install
if [[ -d "$HOME/Library/Python/3.9/bin" ]]; then
  append_path "$HOME/Library/Python/3.9/bin"
fi

#if [[ -d "$HOME/esp/esp-idf/" ]]; then
#  source "$HOME/esp/esp-idf/export.sh"
#fi

# env variable
## XDG-related variables
## reuse existing variables if already set by systemd etc.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.run}"

## in ubuntu
if [[ $RUNOS == "ubuntu" ]]; then
  export NEEDRESTART=a # supress restart message
fi


if [[ -d "${XDG_DATA_HOME}/volta" ]]; then
  export VOLTA_HOME="${XDG_DATA_HOME}/volta"
  append_path "${VOLTA_HOME}/bin"
fi

## gibo
if (( ${+commands[gibo]} )); then
  export GIBO_BOILERPLATES="${XDG_DATA_HOME}/gibo"
fi

# set default editor
if (( ${+commands[editor]} )); then
  # fall-back to update-alternatives symlink if avaiable
  export EDITOR=editor
elif (( ${+commands[nvim]} )); then
  export EDITOR=nvim
else
  export EDTIOR=vi
fi

# activate 1password SSH agent
if [[ -e "${XDG_RUNTIME_DIR}/1password/agent.sock" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/1password/agent.sock"
fi

# set langauge
LC_CTYPE="en_US.UTF-8"
LANG="en_US.UTF-8"

# set playground dir
if [[ -d "$HOME/playground" ]]; then
  export PLAYGROUND_DIR="$HOME/playground"
fi

# cleanup
unfunction append_path
