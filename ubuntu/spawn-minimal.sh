#!/bin/bash
set -eu

# config
SCRIPT_DIR=$(dirname $(realpath -s $0))

# use 'minimal' as default container name
if [[ $# -eq 0 ]]; then
  CONTAINER_NAME='minimal'
else
  CONTAINER_NAME=$1
  shift
fi

# create lxc container for desktop
lxc init \
  --profile default \
  ubuntu-minimal:jammy \
  ${CONTAINER_NAME}

function lxc_push() {
  if [[ $1 =~ '--mode' ]]; then
    _mode=$1; shift
  fi

  lxc file push --gid=0 --uid=0\
    ${_mode} \
    ${SCRIPT_DIR}/${1} \
    ${CONTAINER_NAME}$2
}

echo "Transferring minimum files"
lxc_push --mode=700 minimal.sh /usr/local/bin/minimal-setup.sh
lxc_push --mode=644 etc/netplan/99-inside-lxd.yaml /etc/netplan/99-inside-lxd.yaml

lxc start ${CONTAINER_NAME}
echo "Starting ${CONTAINER_NAME}"
sleep 5 # should wait for systemd to start up
echo
echo "Running minimal-setup"
lxc exec ${CONTAINER_NAME} -- minimal-setup.sh --noninteractive-instance
