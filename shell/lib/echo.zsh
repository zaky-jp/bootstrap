setopt prompt_subst

# @define environment variables
export ECHO_FD=${ECHO_FD:-2}
# @end

# @define default log levels anc colours
if ! (( ${+log_level} )); then
  typeset -Ag log_level
  log_level[debug]=1
  log_level[info]=1
  log_level[warning]=1
  log_level[error]=1
fi 

if ! (( ${+log_colours} )); then
  typeset -Ag log_colours
  log_colours[debug]='grey'
  log_colours[info]='default'
  log_colours[warning]='yellow'
  log_colours[error]='red'
fi
# @end

# @override echo function
function echo() {
  local arg=$1
  local msg="${${arg#*:}# }"
  local level="${arg%:*}"

  if (( ${#level} )) && (( ${#log_colours[$level]} )); then
    if (( ${log_level[${level}]} )); then
      print -P "%F{$log_colours[$level]}${level}: $msg%f" >&${ECHO_FD}
    fi
  else
    builtin echo $@
  fi
}
# @end