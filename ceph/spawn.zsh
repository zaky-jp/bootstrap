#!/usr/bin/env zsh
set -eu

## 0. source common functions
## outcome: $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

## 1. initialisation
## outcome: $LXD_PROFILE and $CONTAINER_NAME, func run() defined
local LXD_PROFILE='default'
local CONTAINER_NAME='microceph'
function run(){
  lxc exec "${CONTAINER_NAME}" -- "$@"
}

## 2. create and start container
## outcome: container created and ready to use
log_notice "Creating microceph container..."
if (lxc list -f json | jq -e '.[].name | in({'${CONTAINER_NAME}':null})' >/dev/null); then
  log_info "${CONTAINER_NAME} already exists."
else
  lxc init \
  --profile "${LXD_PROFILE}" \
  ubuntu-minimal:jammy \
  "${CONTAINER_NAME}"
fi

log_notice "Starting microceph container"
if (lxc list -f json | jq -e '.[] | select(.name == "'${CONTAINER_NAME}'") | .status | in({"Running":null})' >/dev/null); then
  log_info "${CONTAINER_NAME} is already up."
else
  lxc start "${CONTAINER_NAME}"
  log_info "waiting to boot up"
  sleep 3 # should wait for systemd to start up
  run systemctl is-system-running --wait
fi

## 3. install neccesary packages
## outcome: microceph installed using snap
if (run which microceph 1>/dev/null 2>&1); then
  log_info "microceph already present inside a container."
else
  log_info "installing microceph..."
  run snap install --stable microceph
fi

## 4. configure microceph
## outcome: microceph cluster initiated, osd rule modified to suit a single instance
if (run microceph status 1>/dev/null 2>&1); then
  log_info "microceph has been initialised."
else
  log_info "boostrapping microceph cluster"
  run microceph cluster bootstrap
  log_info "setting up dashboard module"
  run ceph config set mgr mgr/dashboard/ssl false
  run ceph mgr module enable dashboard
  log_info "changing osd crush rule to suit a single instance"
  run ceph osd crush rule rm replicated_rule
  run ceph osd crush rule create-replicated single default osd
fi
log_info "refer to readme.md for further instructions..."
