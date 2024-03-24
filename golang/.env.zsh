typeset -x GOPATH="${XDG_DATA_HOME}/go"
typeset -x GOCACHE="${XDG_CACHE_HOME}/go"

path.push "${GOPATH}/bin"
path.clean
