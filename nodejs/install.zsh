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

# @run
echo "info: installing volta..."
install_volta
