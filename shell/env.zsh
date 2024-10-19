# Language & locale
# reference: https://wiki.archlinux.org/title/Locale
# for Linux, it would be better to set /etc/locale.conf or $XDG_CONFIG_HOME/locale.conf
# however, macOS does not support /etc/locale.conf
# hence setting this in the shell configuration file
export LANG="ja_JP.UTF-8"
export LANGUAGE="ja_JP:en_GB:en"
export LC_MESSAGES="en_GB.UTF-8"

# XDG Base Directory Specification
# reference: https://specifications.freedesktop.org/basedir-spec/latest/
# reference: https://wiki.archlinux.org/title/XDG_Base_Directory
() {
	# limit scope of helper function
	set_if() {
		local var=$1
		local value=$2
		if [[ -z "${(P)${var}}" ]]; then
			eval "export ${var}=${value}"
		fi
	}
	get_permission() {
		local file=$1
		perl -MFcntl=':mode' -e 'printf("%o\n", S_IMODE([stat shift]->[2]));' $1
	}
	set_if 'XDG_DATA_HOME' "${HOME}/.local/share"
	set_if 'XDG_CONFIG_HOME' "${HOME}/.config"
	set_if 'XDG_STATE_HOME' "${HOME}/.local/state"
	set_if 'XDG_CACHE_HOME' "${HOME}/.cache"
	set_if 'XDG_RUNTIME_DIR' "${HOME}/.run"
	set_if 'XDG_BIN_HOME' "${HOME}/.local/bin" # recommended in specification, but no standard var name is defined

	if [[ $(get_permission $XDG_RUNTIME_DIR) -ne 700 ]]; then
		chmod 700 "${XDG_RUNTIME_DIR}"
	fi
}

# Load local functions
() {
	emulate -L zsh -o extended_glob -o nonomatch
	fpath=("${XDG_DATA_HOME}/zsh/functions" $fpath)
	for f in "${XDG_DATA_HOME}"/zsh/functions/*; do
		autoload -U "${f:t}"
	done
}

# Add local bin
unshift path $XDG_BIN_HOME

# Source env configuration fragments
# bootstrap should choose to copy or not copy app-specific env configuration fragments to $XDG_CONFIG_HOME/zsh/env.d/
# thus, sourcing all files matching the pattern.
() {
	emulate -L zsh -o extended_glob -o nonomatch
	for f in "${XDG_CONFIG_HOME}"/zsh/env.d/*.zsh; do
		source "${f}"
	done
}

# Bring local bin to the front of the path array
unshift path $XDG_BIN_HOME
typeset -gU PATH path
