#!/bin/bash

set -eu

# config
NERDCTL_RELEASE=https://github.com/containerd/nerdctl/releases/download/v0.19.0/nerdctl-full-0.19.0-linux-amd64.tar.gz

# set profile for containerd
lxc profile create containerd
cat ./lxd/lxd.profile | lxc profile edit containerd

# download latest package
mkdir -p ./pkg
wget -c -O ./pkg/nerdctl-full.tar.gz ${NERDCTL_RELEASE}

# create lxc container for containerd
lxc init \
  --profile default \
  --profile containerd \
  ubuntu-minimal:jammy \
  containerd
lxc file push --gid=0 --uid=0 --mode=700 ../ubuntu/minimal.sh containerd/root/minimal.sh
lxc file push --gid=0 --uid=0 --mode=600 ./pkg/nerdctl-full.tar.gz containerd/root/nerdctl-full.tar.gz
lxc file push --gid=0 --uid=0 --mode=600 ./lxd/netplan.yaml containerd/etc/netplan/99-containerd.yaml

lxc start containerd && sleep 10
lxc exec containerd /root/minimal.sh
lxc exec containerd tar -- --extract --no-same-owner --no-same-permission --gunzip --directory /usr/local -v --file /root/nerdctl-full.tar.gz
lxc exec containerd rm /root/nerdctl-full.tar.gz

lxc exec containerd apt install iptables

lxc exec containerd systemctl -- enable --now containerd
