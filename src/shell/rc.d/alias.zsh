# rm
if (( $+commands[trash] )); then
  alias rm="trash"
fi

# ls
case $RUNOS in
  ubuntu|debian)
	alias ls="ls -aFH --color=auto"
	alias lsl="ls -alF -h --color=auto"
	;;
  macos)
	alias ls="ls -aFH -1 --color=auto"
	alias lsl="ls -alFH@ -h --color=auto"
	;;
esac

# mv
alias mv="mv -i"

# git
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git push"
alias gd="git diff"
alias gds="git diff --staged"
