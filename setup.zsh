#!/usr/bin/env zsh
set -eu

# @fail fast
if ! (( ${+commands[git]} )); then
  echo 'error: git not present in your system. aborting...'
  exit 1
fi

# @define environment variables
(( ${+PLAYGROUND_REPO} )) || typeset -x PLAYGROUND_REPO="zaky-jp/playground"
(( ${+PLAYGROUND_DIR} )) || typeset -x PLAYGROUND_DIR="${HOME}/Development/playground"
# @end

# @override echo to output to stderr
# @output stderr
if ! (( ${+functions[echo]} )); then
  function echo() {
    builtin echo "$@" >&2
  }
fi
# @end

# @define check functions
# @output status code
function playground_dir_exist() {
  [[ -d "${PLAYGROUND_DIR}" ]]
  return $?
}
# @end

# @define run git functions
# @output git changes
function clone_playground() {
	if playground_dir_exist; then
		echo "warning: ${PLAYGROUND_DIR} already exists."
		return 0
	fi
	local remote="https://github.com/${PLAYGROUND_REPO}.git"
	echo "trace: cloning ${remote} to ${PLAYGROUND_DIR}"
  git clone --recurse-submodules --shallow-submodules "${remote}" "${PLAYGROUND_DIR:a}"
}

function fetch_playground_repo() {
	if ! playground_dir_exist; then
		echo "error: ${PLAYGROUND_DIR} does not exist."
		exit 1
	fi
	echo "trace: fetching latest changes from remote git repository"
  git -C "${PLAYGROUND_DIR}" fetch --all --recurse-submodules
}

function update_submodules() {
	if ! playground_dir_exist; then
		echo "error: ${PLAYGROUND_DIR} does not exist."
		exit 1
	fi
  git -C "${PLAYGROUND_DIR}" submodule update --init --remote --recursive --recommend-shallow
}
# @end

# @run
mkdir -p ~/Development
echo "info: cloning ${PLAYGROUND_REPO} to ${PLAYGROUND_DIR}..."; {
	clone_playground
	fetch_playground_repo
	update_submodules
}

echo "info: linking editorconfig..."
ln -s "${PLAYGROUND_DIR}/.editorconfig" "${HOME}/Development/.editorconfig"

zsh "${PLAYGROUND_DIR}/shell/configure.zsh"
