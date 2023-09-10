#!/usr/bin/env zsh
set -eu

## importing common functions
## outcome: $PLAYGROUND_DIR/common/zsh-functions/ imported
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

## initialisation
## outcome: $LXD_PROFILE, $LXD_VOLUME_GROUP, $LXD_THINPOOL, $LXD_PARTITION, $LXD_PARENT_NIC set
local function get_nic() {
  # get first nic that is up, but not loopback
  local nic=$(ip -j -details link show up | jq -r 'first(.[] | select(.link_type != "loopback")| .ifname)')
  echo $nic
}
# general lxd config
LXD_PROFILE=${LXD_PROFILE:-'default'} # profile which storage and network are added to
# storage config
LXD_VOLUME_GROUP=${LXD_VOLUME_GROUP:-'ubuntu-vg'} # lvm volume group; defaults to ubuntu volume group
LXD_THINPOOL=${LXD_THINPOOL:-'lxd'} # lvm thin pool name
LXD_PARTITION=${LXD_PARTITION:-'lvm'} # lxd partition name
# network config
PARENT_NIC=${PARENT_NIC:-$(get_nic)} # nic macvlan should bind to
LXD_BRIDGE_HOST_ADDRESS='172.31.97.10/24' # host ip address (in cidr form) for bridge network
LXD_BRIDGE_DHCP_RANGES='172.31.97.20-172.31.97.254' # bridge dhcp ranges
LXD_VLAN_ID=${LXD_VLAN_ID:-'1900'} # vlan id for guest network

## installing lxd
## outcome: lxd and uidmap installed
log_notice "Installing lxd and dependencies..."
autoload +X is-at-least
if ( is-at-least '5.12' "${snap_list[lxd]}" ); then # require 5.12+ for LXD-UI
  log_info "lxd already installed"
else
  if (( ${+snap_list[lxd]} )); then
    snap refresh --stable lxd
  else
    snap install --stable lxd
  fi
fi
if (( ${+apt_list[uidmap]} )); then
  log_info "uidmap already installed"
else
  apt-get install uidmap
fi

## configuring lxd
## outcome: uidmap, storage, network, LXD-UI, cloud-init configured 
log_notice "Starting configuration..."
## uidmap
# reserve uid/gid for lxd, so that it will not conflict with other container runtime
# refer: https://wiki.gentoo.org/wiki/Subuid_subgid
# refer: https://lxd-ja.readthedocs.io/ja/latest/userns-idmap/
if ! ( grep -q "lxd:1000000:1000000000" /etc/subuid ); then
  log_info "append /etc/subuid and /etc/subgid"
  cat <<EOS | sudo tee -a /etc/subuid /etc/subgid >/dev/null
root:1000000:1000000000
lxd:1000000:1000000000
EOS
fi
# enable ping and <1024 port access for rootless users
if [[ ! -e /etc/sysctl.d/99-rootless.conf ]]; then
  log_info "enabling ping and <1024 port access"
  cat <<EOS | sudo tee /etc/sysctl.d/99-rootless.conf >/dev/null
net.ipv4.ping_group_range = 0 2147483647
net.ipv4.ip_unprivileged_port_start=0
EOS
  sudo sysctl --system
fi

## storage
# create lxd storage partition on lvm
if (lxc storage list -f json | jq -r ".[].name" | grep -q "${LXD_PARTITION}"); then
  log_info "lxd storage partition already exists. skipping..."
else
  log_info "creating lxd storage partition"
  lxc storage create "${LXD_PARTITION}" \
    lvm \
    source="${LXD_VOLUME_GROUP}" \
    lvm.use_thinpool=true \
    lvm.thinpool_name="${LXD_THINPOOL}" \
    lvm.vg.force_reuse=true
  lxc profile device add "${LXD_PROFILE}" root disk path=/ pool="${LXD_PARTITION}"
fi

## network
local br_interface='lxdbr0'
local vlan_interface='lxdmacv0'
# setup bridge network
if (lxc network list -f json | jq -r ".[].name" | grep -q "${br_interface}"); then
  log_info "${br_interface} already exists. skipping..."
else
  lxc network create "${br_interface}" --type=bridge ipv4.address="${LXD_BRIDGE_HOST_ADDRESS}" ipv4.dhcp.ranges="${LXD_BRIDGE_DHCP_RANGES}"
  lxc profile device add "${LXD_PROFILE}" eth0 nic network="${br_interface}"
fi
# setup macvlan network
if (lxc network list -f json | jq -r ".[].name" | grep -q "${vlan_interface}"); then
  log_info "${vlan_interface} already exists. skipping..."
else
  lxc network create "${vlan_interface}" --type=macvlan parent="${PARENT_NIC}" vlan="${LXD_VLAN_ID}"
  lxc profile device add "${LXD_PROFILE}" eth1 nic network="${vlan_interface}"
fi
# setup cloud-init to enable dhcp
# TODO: fix default gateway hardcoded
cat <<EOS | lxc profile set "$LXD_PROFILE" cloud-init.network-config -
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: "true"
    eth1:
      dhcp4: "true"
      routes:
      - to: default
        via: 172.19.0.1
EOS

# LXD-UI
sudo snap set lxd ui.enable=true
sudo snap restart --reload lxd
lxc config set core.https_address "[::]:443"

# cloud-init / user-data
cat "${PLAYGROUND_DIR}/ubuntu/cloud-init/minimal.user-data.yaml" | lxc profile set "$LXD_PROFILE" cloud-init.user-data -

# add ubuntu-minimal as upstream
lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases