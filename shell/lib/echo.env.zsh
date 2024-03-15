setopt prompt_subst

# @define environment variables
export ECHO_FD=${ECHO_FD:-2}
# @end

# @define default log levels anc colours
if ! (( ${+log_level} )); then
  typeset -Ag log_level
  log_level[debug]=0
  log_level[info]=1
  log_level[warning]=1
  log_level[error]=1
fi 

if ! (( ${+log_colours} )); then
  typeset -Ag log_colours
  log_colours[debug]='grey'
  log_colours[info]='green'
  log_colours[warning]='yellow'
  log_colours[error]='red'
fi
# @end

# @override echo function
function echo() {
  local arg=$1
  local msg="${${arg#*:}# }"
  local level="${arg%:*}"
  local caller

  if (( ${#log_level[(I)${level}]} )) && (( ${#log_colours[(I)${level}]} )) && (( ${#funcstack:-0} )); then
    if ! (( ${log_level[${level}]} )); then
      return 0
    fi

    if (( ${#funcstack} > 1 )); then
      caller=${funcstack[2]}
    else
      caller=${funcstack[1]}
    fi
    print -P "%B%F{$log_colours[$level]}${level}:%f%b[${caller}] $msg" >&${ECHO_FD}
  else
    builtin echo $@
  fi
}
# @end