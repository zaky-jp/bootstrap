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
## outcome: env vars and local vars initialised, func run() defined
DEFAULT_PROFILE="${DEFAULT_PROFILE:-default}"
CONTAINER_NAME="${CONTAINER_NAME:-microceph}"
CEPH_PROFILE="${CEPH_PROFILE:-microceph}"
local password=$(openssl rand -base64 12 | fold -w 10 | head -1)
local passfile="/var/snap/microceph/current/conf/password.txt"
typeset -a target_devs
target_devs=($(
  whiptail --noitem --nocancel --separate-output\
  --checklist "select disks to be managed by ceph" 15 40 5\
  $(lsblk -J | jq -rj '.blockdevices | .[] | select(.type == "disk") | " " + .name + " OFF"')\
  3>&1 1>&2 2>&3
))

function run(){
  lxc exec "${CONTAINER_NAME}" -- "$@"
}

## 2. create and start container
## outcome: container created and ready to use
log_notice "Preparing microceph container..."
if (lxc profile list -f json | jq -r '[.[].name] | contains(["env.CEPH_PROFILE"])' >/dev/null) then
  log_info "LXD profile '${CEPH_PROFILE}' already exists."
else
  log_info "Creating LXD profile '${CEPH_PROFILE}'"
  lxc profile create microceph
  for d in ${target_devs}; do
    log_info "Adding /dev/${d} to LXD profile"
    lxc profile device add "${CEPH_PROFILE}" $d unix-block path=/dev/$d
  done
  lxc profile set "${CEPH_PROFILE}" security.syscalls.intercept.mount true
fi

if (lxc list -f json | jq -e '.[].name | in({'"${CONTAINER_NAME}"':null})' >/dev/null); then
  log_info "${CONTAINER_NAME} already exists."
else
  log_info "Creating microceph container"
  lxc init \
  --profile "${DEFAULT_PROFILE}" \
  --profile "${CEPH_PROFILE}" \
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
# cluster config
if (run microceph status 1>/dev/null 2>&1); then
  log_info "microceph has been initialised."
else
  log_info "boostrapping microceph cluster"
  run microceph cluster bootstrap
  log_info "changing osd crush rule to suit a single instance"
  run ceph osd crush rule rm replicated_rule
  run ceph osd crush rule create-replicated single default osd
  log_info "wait for configuration to propagate"
  sleep 3 # TODO; understand what to wait for
  log_info "setting up dashboard module"
  run ceph mgr module enable dashboard
  run ceph config set mgr mgr/dashboard/ssl false
  log_info "one-off password has been set as: ${password}"
  echo "$password" | run tee "$passfile" >/dev/null
  run ceph dashboard ac-user-create --pwd_update_required ceph_admin -i "$passfile" administrator >/dev/null
  run ceph mgr module disable dashboard # need to restart dashboard mod
  run ceph mgr module enable dashboard
fi
# adding disks
log_info "adding blockdevices to ceph"
for d in ${target_devs}; do
  if (read -q "?Confirm wiping /dev/${d} [y/n]"); then
    run microceph disk add --wipe /dev/${d}
  fi
done
log_info "enabling rgw"
microceph enable rgw
