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
export DEFAULT_PROFILE="${DEFAULT_PROFILE:-default}"
export CONTAINER_NAME="${CONTAINER_NAME:-microk8s}"
export K8S_PROFILE="${K8S_PROFILE:-kubernetes}"

function run(){
  lxc exec "${CONTAINER_NAME}" -- "$@"
}

## 2. create and start container
## outcome: container created and ready to use
log_notice "Preparing ${CONTAINER_NAME} container..."
if (( ${+apt_list[conntrack]} )); then
  log_info "conntrack already installed."
else
  log_info "installing conntrack"
  apt-get install conntrack
fi

if (lxc profile list -f json | jq -e '[.[].name] | contains([env.K8S_PROFILE])' >/dev/null); then
  log_info "LXD profile '${K8S_PROFILE}' already exists."
else
  log_info "Creating LXD profile '${K8S_PROFILE}'"
  lxc profile create "${K8S_PROFILE}"
  #lxc profile set "${K8S_PROFILE}" security.syscalls.intercept.mount true
  cat <<EOS | lxc profile edit "${K8S_PROFILE}"
config:
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,xt_conntrack,br_netfilter
  raw.lxc: |
    lxc.mount.auto=proc:rw sys:rw cgroup:rw
    lxc.apparmor.profile=unconfined
  security.nesting: "true"
  security.privileged: "true"
EOS
  #lxc profile set "${K8S_PROFILE}" boot.autostart true
  lxc profile device add "${K8S_PROFILE}" kmsg unix-char source=/dev/kmsg
fi

if (lxc list -f json | jq -e '[.[].name] | contains([env.CONTAINER_NAME])' >/dev/null); then
  log_info "${CONTAINER_NAME} already exists."
else
  log_info "Creating ${CONTAINER_NAME} container"
  lxc init \
  --profile "${DEFAULT_PROFILE}" \
  --profile "${K8S_PROFILE}" \
  ubuntu-minimal:jammy \
  "${CONTAINER_NAME}"
fi

log_notice "Starting ${CONTAINER_NAME} container"
if (lxc list -f json | jq -e '.[] | select(.name == env.CONTAINER_NAME) | .status == "Running"' >/dev/null); then
  log_info "${CONTAINER_NAME} is already up."
else
  lxc start "${CONTAINER_NAME}"
  log_info "waiting to boot up"
  sleep 3 # should wait for systemd to start up
  run systemctl is-system-running --wait
  # donno why but setting apparmor=confined will fail to access /dev/rfkill
  # maybe above config opens up permission to run systemd-rfkill
  # just run script twice should do the trick
fi

## 3. install neccesary packages
## outcome: microk8s installed using snap
log_notice "Installing microk8s"
run snap install microk8s --classic


