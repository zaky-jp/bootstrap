typeset -x VOLTA_HOME="$XDG_CONFIG_HOME/volta"
if [[ -d "$VOLTA_HOME" ]]; then
	path.push "$VOLTA_HOME/bin"
fi
