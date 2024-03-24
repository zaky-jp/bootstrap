#!/usr/bin/env zsh
set -eu
(( ${+PLAYGROUND_DIR} )) || { echo "error: PLAYGROUND_DIR is not set."; exit 1; }

# @define environment variables
source "${PLAYGROUND_DIR}/nodejs/.env.zsh"
# @end

# @define check function
function volta_exist() {
	(( ${+commands[volta]} ))
	return $?
}

# @define install function
function install_volta() {
	if volta_exist; then
		echo "warning: volta is already installed."
		return
	fi

	curl -fsSL https://get.volta.sh | bash -s -- --skip-setup
}

function configure_volta() {
	if ! check_dir_exist "${VOLTA_HOME}"; then
		mkdir -p "${VOLTA_HOME}"
	fi

	if check_file_exist "${VOLTA_HOME}/env.zsh"; then
		echo "warning: ${VOLTA_HOME}/env.zsh already exists. skipping..."
		return
	fi
	echo "debug: symlinking .env file"
	ln -s "${PLAYGROUND_DIR}/nodejs/.env.zsh" "${VOLTA_HOME}/env.zsh"
}

# @run
echo "info: installing volta..."
install_volta
configure_volta
