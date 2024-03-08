# @return fast
if [[ $RUNOS != "ubuntu" ]]; then
  return
fi

# @define apt configs
export NEEDRESTART=a # supress restart message
# @end


