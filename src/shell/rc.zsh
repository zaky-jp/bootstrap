# Source powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source rc configuration fragments
# bootstrap should choose to copy or not copy app-specific rc configs to $XDG_CONFIG_HOME/zsh/rc.d/
# thus, sourcing all files matching the pattern.
() {
	emulate -L zsh -o extended_glob -o nonomatch
	for f in "${XDG_CONFIG_HOME}"/zsh/rc.d/*.zsh; do
		source "${f}"
	done
}

# Compile compdump for faster completion
#update-compdump
