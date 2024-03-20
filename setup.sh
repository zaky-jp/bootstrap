#!/usr/bin/env bash
set -eu

# @define environment variables
typeset -g GITHUB_REPO="zaky-jp/playground"
typeset -g REPLY # reserve for valsub (bash >5.3)
# @end

# @override echo to output to stderr
# @output stderr
function echo() {
  builtin echo "$@" >&2
}
# @end

# @define check functions
# @output status code
function zsh_exist() {
  which zsh 1>/dev/null 2>&1
  return $?
}

# @define perform functions
# @output $REPLY
function get_setup_script() {
	echo "debug: downloading setup script"; {
		REPLY=$(curl -sSfL "https://raw.githubusercontent.com/${GITHUB_REPO}/main/setup.zsh")
	}
}

# @output file manupulation
function install_zsh_with() {
	if zsh_exist; then
		echo "warning: zsh is already installed."
		return
	fi

	local pkgmgr=$1
	case $pkgmgr in
		apt)
			echo "trace: using apt package manager"; {
				install_zsh_with_apt
			}
			;;
		*)
			echo "error: unsupported package manager."
			return 1
			;;
	esac
}

function install_zsh_with_apt() {
  export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-'readline'} # allowing programmatic access to apt-get
	echo "info: requesting sudo access to install zsh..."
	echo "trace: apt update"; {
  	sudo --preserve-env=DEBIAN_FRONTEND apt-get -y update
	}
	echo "trace: apt install zsh"; {
  	sudo --preserve-env=DEBIAN_FRONTEND apt-get -y install zsh
	}
	echo "trace: regenate locales"; {
  	sudo locale-gen en_US.UTF-8
  	sudo dpkg-reconfigure locales
	}
}
# @end

# @run
if [[ $(lsb_release --id --short) == 'Ubuntu' ]]; then
	install_zsh_with apt
else
  echo "error: zsh was not installed."
  echo "error: please manually install zsh to continue with the setup"
  exit 1
fi

download_setup_script; {
	builtin echo "$REPLY" | zsh
}
# @end