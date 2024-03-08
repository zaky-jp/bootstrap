# @define XDG variables
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.run}"
# @end

# @define playground directory
export PLAYGROUND_DIR="${PLAYGROUND_DIR:-${HOME}/playground}"
# @end

# @store zsh environment file paths
export ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}"
if (( ${+zsh_files} )); then
  typeset -Ax zsh_files
  zsh_files[lib]="${PLAYGROUND_DIR}/shell/lib"
  if [ -r '/etc/zsh/zshenv' ]; then
    zsh_files[env]='/etc/zsh/zshenv'
  else
    zsh_files[env]='/etc/zshenv'
  fi
fi
# @end

# @store zshlib file paths
if (( ${+zsh_libs} )); then
  typeset -Ax zsh_libs
  () {
    emulate -L zsh extended_glob
    for f in "${zsh_files[lib]}"/*; do
      zsh_libs[${f:t:r}]="${f:a}"
    done
  }
fi
# @end

# @configure echo
# refer: shell/lib/echo_enhance.zsh
export ECHO_FD=2
# @end

# @define RUNOS variable
if (( ${+RUNOS} )); then
  case $OSTYPE in
    "linux-gnu")
      export RUNOS="${(L)$(lsb_release --id --short)}" # convert to lowercase
      ;;
    "darwin"*)
      export RUNOS="macos"
      ;;
    *)
      RUNOS="${OSTYPE}"
      ;;
  esac
fi
# @end