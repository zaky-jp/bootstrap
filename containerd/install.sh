#!/usr/bin/env bash
set -eu

##########################
# Configuration
##########################
NERDCTL_VERSION='0.22.0'
# ARCH='amd64'
ARCH='arm64'
WORKDIR="${WORKDIR:-}"

##########################
# place containerd packages
##########################
# TODO: create apt package to manage release files
NERDCTL_RELEASE="https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz"
NERDCTL_CHECKSUM="https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/SHA256SUMS"

# download latest package and push
# if WORKDIR is unset create one in /tmp
if [[ -z "${WORKDIR}" ]]; then
  WORKDIR="$(mktemp -d)"
fi

curl \
  --progress-bar \
  --create-dirs \
  --show-error \
  --location \
  --output-dir "${WORKDIR}" \
  --remote-name "${NERDCTL_RELEASE}" \
  --remote-name "${NERDCTL_CHECKSUM}"

saved_path="$PWD"
cd "${WORKDIR}"
sha256sum --check --ignore-missing SHA256SUMS
cd "${saved_path}"

sudo tar --extract --no-same-owner --no-same-permission --gunzip -v \
  --directory /usr/local \
  --file "${WORKDIR}/nerdctl-full-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz"

sudo apt-get install uidmap iptables
sudo systemctl daemon-reload

# rootless setup
containerd-rootless-setuptool.sh install
containerd-rootless-setuptool.sh install-buildkit
containerd-rootless-setuptool.sh install-bypass4netnsd

