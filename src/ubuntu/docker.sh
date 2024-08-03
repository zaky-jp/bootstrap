#!/bin/bash
set -eu

# parse options
function _help() {
  cat <<EOS
Usage: docker.sh [option]
  --noninteractive-instance
  --help
EOS
  exit 0
}

# initialisation
_NONINTERACTIVE=0

while (( $# > 0 )); do
  case $1 in
    --noninteractive-instance)
      _NONINTERACTIVE=1
      shift
      ;;
    --help)
      _help
      ;;
  esac
done

## script may not be run under interactive shell
if [[ ${_NONINTERACTIVE} -eq 1 ]]; then
  export DEBIAN_FRONTEND='noninteractive'
  export NEEDRESTART_MODE='a'
else
  export DEBIAN_FRONTEND='readline'
fi

# adopt from https://docs.docker.com/engine/install/ubuntu/
## install prerequisite packages
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get update
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get install ca-certificates curl gnupg lsb-release
## place keyring
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
## install docker
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get update
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
