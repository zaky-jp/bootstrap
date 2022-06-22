#!/bin/bash
set -eu

# parse options
function _help() {
  cat <<EOS
Usage: minimal.sh [option]
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

# wait for system startup
echo "Checking system boot status..."
systemctl is-system-running --wait

# apt configs
echo "Deploying apt config..."
## /etc/apt/apt.conf
cat <<EOS | sudo tee /etc/apt/apt.conf 1>/dev/null
APT {
  Get {
    Assume-Yes "true";
  };
};
EOS

## /etc/apt/apt.conf.d/noninteractive.conf
if [[ ${_NONINTERACTIVE} -eq 1 ]]; then
  sudo mkdir -p /etc/apt/apt.conf.d/
  cat <<EOS | sudo tee /etc/apt/apt.conf.d/noninteractive.conf 1>/dev/null
APT {
  Install-Recommends "false";
};
EOS
fi

## /etc/apt/sources.list
cat <<EOS | sudo tee /etc/apt/sources.list 1>/dev/null
deb mirror+file:/etc/apt/mirrors.txt jammy main restricted universe multiverse
deb mirror+file:/etc/apt/mirrors.txt jammy-updates main restricted universe multiverse
deb mirror+file:/etc/apt/mirrors.txt jammy-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
EOS

## /etc/apt/mirrors.txt
cat <<EOS | sudo tee /etc/apt/mirrors.txt 1>/dev/null
https://ftp.udx.icscoe.jp/Linux/ubuntu/	priority:1
http://jp.archive.ubuntu.com/ubuntu/	priority:2
http://archive.ubuntu.com/ubuntu/
EOS

## even running minimal-ubuntu container we still want to cache apt packages
if [[ -r /etc/apt/apt.conf.d/docker-clean ]]; then
  sudo rm /etc/apt/apt.conf.d/docker-clean
fi

# update to latest packages
## script may not be run under interactive shell
if [[ ${_NONINTERACTIVE} -eq 1 ]]; then
  export DEBIAN_FRONTEND='noninteractive'
  export NEEDRESTART_MODE='a'
else
  export DEBIAN_FRONTEND='readline'
fi

echo "Installing ca-certificates..."
## check if ca-certificates is already installed
if dpkg-query --show -f '${package}\n' | grep --silent 'ca-certificates'; then
  echo "'ca-certificates' already present."
else
  # install ca-certificates
  sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get \
    --option "Acquire::https::Verify-Peer=false" update
  sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get \
    --option "Acquire::https::Verify-Peer=false" install \
    --no-install-recommends ca-certificates
fi

# upgrading to latest package
echo
echo "Upgrading apt packages..."
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get update
sudo --preserve-env=DEBIAN_FRONTEND,NEEDRESTART_MODE apt-get upgrade
echo
echo "Upgrading snap installs..."
sudo snap refresh

