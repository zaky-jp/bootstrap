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
    RUNOS='darwin'
    ;;
  *)
    RUNOS="${OSTYPE}"
    ;;
esac
export RUNOS

# configure path
if [[ ${RUNOS} == "darwin" ]]; then
  local HOMEBREW_DIR
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    HOMEBREW_DIR="/opt/homebrew"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    HOMEBREW_DIR="/usr/local"
  fi

  if [[ -n "${HOMEBREW_DIR}" ]]; then
    append_path "${HOMEBREW_DIR}/bin"
    append_path "${HOMEBREW_DIR}/sbin"

    # program-specific
    # gcp sdk
    if [[ -r "${HOMEBREW_DIR}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]]; then
      source "${HOMEBREW_DIR}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    fi
  fi
fi

if [[ -d "${HOME}/.local/bin" ]]; then
  # systemd expects user binary in this directory
  append_path "${HOME}/.local/bin"
fi

# declare XDG-related variables
# reuse existing variables if already set by systemd etc.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.run}"

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

# cleanup
unfunction append_path
