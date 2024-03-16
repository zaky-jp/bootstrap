#!/usr/bin/env zsh
set -eu

# @fail fast
if ! (( ${+PLAYGROUND_DIR} )); then
  echo 'error: $PLAYGROUND_DIR is not set'
  exit 1
fi 
# @end

# @define dotfile assets
typeset -A zsh_dotfiles
zsh_dotfiles[.zshenv]="${PLAYGROUND_DIR}/shell/dotfiles/env.zsh"
zsh_dotfiles[.zshrc]="${PLAYGROUND_DIR}/shell/dotfiles/rc.zsh"
zsh_dotfiles[.zprofile]="${PLAYGROUND_DIR}/shell/dotfiles/profile.zsh"
#zsh_dotfiles[.zlogin]="${PLAYGROUND_DIR}/shell/dotfiles/login.zsh"
# @end

# @define check functions
# @output status code
function check_zdotdir_hardcoded() {
  local cmd='export ZDOTDIR="$HOME/.config/zsh"'
  grep -q "${cmd}" "${zsh_files[env]}"
  return $?
}

function check_echo_override_hardcoded() {
  local cmd='source "$HOME/playground/shell/lib/echo.env.zsh"'
  grep -q "${cmd}" "${zsh_files[env]}"
  return $?
}

# @define perform functions
# @output file changes
function create_zdotdir() {
  if [[ -d "${ZDOTDIR}" ]]; then
    echo "debug: ZDOTDIR already exists. skipping..."
  else
    echo "info: creating ZDOTDIR..."
    mkdir -p "${ZDOTDIR}"
  fi
}

function hardcode_zdotdir() {
  echo "info: hardcoding ZDOTDIR path..."
  local cmd='export ZDOTDIR=$HOME/.config/zsh'
  echo 'debug: adding $cmd to '"${zsh_files[env]}"
  echo "info: requesting sudo privilege to write to system files"
  builtin echo $cmd | sudo tee -a "${zsh_files[env]}" >/dev/null
}

function hardcode_echo_override() {
  echo "info: hardcoding echo override..."
  local cmd='if [[ -r "$HOME/playground/shell/lib/echo.env.zsh" ]]; then'"\n"
  cmd+='  source "$HOME/playground/shell/lib/echo.env.zsh"'"\n"
  cmd+='fi"${PLAYGROUND_DIR}/shell/lib/echo.env.zsh"'
  echo "debug: adding source to echo.env.zsh to '${zsh_files[env]}'"
  echo "info: requesting sudo privilege to write to system files"
  cat "$echo_lib_path" | sudo tee -a "${zsh_files[env]}" >/dev/null
}

function symlink_to_zdotdir() {
  [[ -d "${ZDOTDIR}" ]] || { echo "error: ZDOTDIR is not a directory."; exit 1; }
  local target="${ZDOTDIR}/$1"
  local source="$2"

  if [[ -e "${target}" ]] || [[ -h "${target}" ]]; then # macos needs -h to follow symlink
    echo "debug: ${target} already exists. skipping..."
  else
    echo "info: symlinking ${source:t}"
    ln -s "${source}" "${target}"
  fi
}
# @end

# @run
(( ${+ZDOTDIR} )) || source "${PLAYGROUND_DIR}/shell/dotfiles/env.zsh"
# ensure variables are set
(( ${+ZDOTDIR} )) || { echo "error: ZDOTDIR is not set."; exit 1; }
(( ${+zsh_files[env]} )) || { echo "error: zsh_files[env] is not set."; exit 1; }

# prepare zdotdir
create_zdotdir

# 'ZDOTDIR' has to be hardcoded to system/zshenv file 
if check_zdotdir_hardcoded; then
  echo "debug: ZDOTDIR path is already hardcoded."
else
  hardcode_zdotdir
fi

# 'echo' function to be hardcoded to avoid flooding with debug message
if check_echo_override_hardcoded; then
  echo "debug: echo override is already hardcoded."
else
  hardcode_echo_override
fi

# symlink dotfiles
for key in ${(k)zsh_dotfiles}; do
  symlink_to_zdotdir "${key}" "${zsh_dotfiles[${key}]}"
done
# @end