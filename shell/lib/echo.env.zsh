setopt prompt_subst

# @define environment variables
typeset -x ECHO_FD=${ECHO_FD:-2}
typeset -x ECHO_TRAIL=${ECHO_TRAIL:-"*"}
typeset -x ECHO_SHOW_CALLER=${ECHO_SHOW_CALLER:-0}
# @end

# @define default log levels anc colours
if ! (( ${+log_level} )); then
  typeset -Ax log_level
	log_level[trace]=0
  log_level[debug]=1
  log_level[info]=1
  log_level[warning]=1
  log_level[error]=1
fi

if ! (( ${+log_colours} )); then
  typeset -Ax log_colours
	log_colours[trace]='black'
  log_colours[debug]='black'
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

    {
      if [[ $level == "info" || $level == "error" ]]; then
        print -Pn "%B%F{$log_colours[$level]}${ECHO_TRAIL}"
      elif [[ $level == "warning" ]]; then
        print -Pn "%F{$log_colours[$level]}"
        printf '%*s' $(( ${#ECHO_TRAIL}+1 ))""
      else
        printf '%*s' $(( ${#ECHO_TRAIL}+1 )) ""
      fi
      print -Pn " ${msg}%f"

      if [[ $level == "info" || $level == "error" ]]; then
        print -Pn "%b"
      fi

      if (( ${ECHO_SHOW_CALLER} )); then
       print -Pn " %F{black}[@${caller}]%f"
      fi
      print -P
    } >&${ECHO_FD}
  else
    builtin echo $@
  fi
}
# @end