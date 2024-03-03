#!/usr/bin/env bash
set -eu

# @define environment variables
export GITHUB_REPO="zaky-jp/playground"
export TARGET_DIR="${HOME}/playground"
declare -Ax submodule_wanted_files
submodule_wanted_files+=( ["alacritty/upstream"]="extra/alacritty.info" )
submodule_wanted_files+=( ["neovim/jetpack"]="plugin/jetpack.vim" )
# @end

# @define echo helper functions
# @output stdout or stderr
function echo2() {
  echo "$@" >&2
}
# @end

# @define check status functions
# @output status code
function check_running_zsh () {
  [[ "${0##*/}" == 'zsh' ]]
  return $?
}

function check_running_bash () {
  # associative array is available in bash 4 or later
  [[ "${BASH_VERSINFO:-0}" -ge 4 ]]
  return $?
}

function check_git_presence() {
  which git 1>/dev/null 2>&1
  return $?
}

function check_clone_status() {
  [[ -d "${TARGET_DIR}/.git" ]]
  return $?
}

function check_submodule_sparse_checkout() {
  local submodule_name=$1
  [[ $(git -C "${TARGET_DIR}/${submodule_name}" config --get core.sparsecheckout) == 'true' ]]
  return $?
}
# @end

# @define perform functions
# @output file changes
function clone_git_repository() {
  git clone --recurse-submodules "https://github.com/${GITHUB_REPO}.git" "${TARGET_DIR}"
}

function apply_sparse_checkout() {
  local submodule_name=$1
  local target_files=$2
    git -C "${TARGET_DIR}/${submodule_name}" config core.sparsecheckout true
    echo "${target_files}" | tee "${TARGET_DIR}/.git/modules/${submodule_name}/info/sparse-checkout" >/dev/null
    git -C "${TARGET_DIR}/${submodule_name}" read-tree -mu HEAD 
}

function pull_repository() {
  git fetch --all --recurse-submodules
}

function update_submodules() {
  git submodule update --remote --recursive
}

# @run
if check_running_bash || check_running_zsh ; then
  echo -n # do nothing
else
  echo2 "this script requires bash 4 or later, or zsh"
  echo2 "aborting..."
  exit 1
fi

if ! check_git_presence; then
  echo2 "git not present in your system."
  echo2 "retry after installing git. aborting..."
  exit 1
fi

if check_clone_status; then
  echo "${TARGET_DIR} already exists and managed by git"
  echo "skip cloning process..."
else
  echo "cloning ${GITHUB_REPO} to ${TARGET_DIR}..."
  clone_git_repository
fi

_perform() {
  submodule=$1
  if ! check_submodule_sparse_checkout "${submodule}"; then
    echo "applying sparse checkout for ${submodule}..."
    apply_sparse_checkout "${submodule}" "${submodule_wanted_files[${submodule}]}"
  else
    echo "sparse checkout already applied for ${submodule}"
  fi
}

# need different parameter expansion for zsh and bash
if check_running_zsh; then
  for submodule in ${(k)submodule_wanted_files}; do
    _perform "$submodule"
  done
else
  for submodule in "${!submodule_wanted_files[@]}"; do
    _perform "$submodule"
  done
fi

pull_repository
update_submodules
# @end