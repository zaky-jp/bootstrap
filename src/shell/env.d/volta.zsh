if (( $+commands[volta] )); then
	export VOLTA_HOME="${XDG_DATA_HOME}/volta"
	unshift path "${VOLTA_HOME}/bin"
fi
