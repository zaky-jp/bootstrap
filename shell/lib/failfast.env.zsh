function fail_unless_command_exists() {
	local command=$1
	if (( ${+commands[${command}]} )); then
		return
	else
	  echo "error: ${command} is required. aborting..."
		exit 1
	fi
}
