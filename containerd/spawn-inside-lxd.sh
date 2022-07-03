#!/bin/bash
set -eu

#####
# configs
#####

PLAYGROUND_HOME=$HOME/playground
CONTAINER_NAME=containerd
# containerd network range
CIDR=192.168.100.0/24
GATEWAY=192.168.100.1

# containerd release info
# TODO: create apt package to manage release files
NERDCTL_RELEASE='https://github.com/containerd/nerdctl/releases/download/v0.21.0/nerdctl-full-0.21.0-linux-amd64.tar.gz'
NERDCTL_CHECKSUM='https://github.com/containerd/nerdctl/releases/download/v0.21.0/SHA256SUMS'

#####
# dockerfile style helper functions
#####
function RUN() {
  lxc exec ${CONTAINER_NAME} -- "$@"
}

function ADD() {
  if [[ $1 == '--mode' ]]; then
    _mode=$2
    shift; shift
  else
    _mode=644
  fi
  # make root owner
  lxc file push --uid 0 --gid 0 --mode ${_mode} \
    $1 \
    ${CONTAINER_NAME}/$2
}

#####
# Create and start container
#####

# check if containerd profile is already set
lxc profile show containerd 1>/dev/null 2>&1

# if profile is not present create one
if [[ $? -eq 0 ]]; then
  cat << EOS | lxc profile edit containerd
config:
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
  raw.lxc: lxc.mount.auto=proc:rw sys:rw
  security.privileged: "true"
  security.nesting: "true"
  security.syscalls.intercept.mknod: "true"
  security.syscalls.intercept.setxattr: "true"
EOS
fi

# check if container already exists
if [[ $(lxc list ^${CONTAINER_NAME}$  --format csv --columns n) ]]; then
  echo "${CONTAINER_NAME} already exists."
  exit 1
fi

# create lxc container for containerd
lxc init --profile default --profile containerd ubuntu-minimal:jammy ${CONTAINER_NAME}

# add minimal files and run initial setup
ADD --mode 700 ${PLAYGROUND_HOME}/ubuntu/minimal.sh /usr/local/bin/setup-minimal.sh
ADD ${PLAYGROUND_HOME}/ubuntu/etc/netplan/99-inside-lxd.yaml /etc/netplan/99-inside-lxd.yaml
lxc start ${CONTAINER_NAME}
sleep 5
RUN setup-minimal.sh --noninteractive-instance

#####
# place containerd packages
#####

# download latest package and push
if [[ ! -f ${PLAYGROUND_HOME}/containerd/pkg/$(basename ${NERDCTL_RELEASE}) ]]; then
  curl \
    --progress-bar \
    --create-dirs \
    --show-error \
    --location \
    --output-dir ./pkg \
    --remote-name ${NERDCTL_RELEASE} \
    --remote-name ${NERDCTL_CHECKSUM}

  saved_path=$PWD
  cd ./pkg
  sha256sum --check --ignore-missing SHA256SUMS
  cd ${saved_path}
fi

ADD --mode 600 \
 ${PLAYGROUND_HOME}/containerd/pkg/$(basename ${NERDCTL_RELEASE}) \
 /root/nerdctl-full.tar.gz
RUN tar --extract --no-same-owner --no-same-permission --gunzip -v \
  --directory /usr/local \
  --file /root/nerdctl-full.tar.gz
RUN rm /root/nerdctl-full.tar.gz
RUN apt-get install uidmap iptables
RUN systemctl daemon-reload
RUN systemctl enable --now containerd

# rootless setup
# TODO: find out why this does not run inside lxd using proper kernel modules
# RUN su -l ubuntu -c 'containerd-rootless-setuptool.sh install'
# RUN su -l ubuntu -c 'containerd-rootless-setuptool.sh install-buildkit'
# RUN su -l ubuntu -c 'containerd-rootless-setuptool.sh install-bypass4netnsd'

