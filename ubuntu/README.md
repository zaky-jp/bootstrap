# Usage
*Prerequisite*: `curl` command.

## Minimal boostrapping
If `which curl` fails, execute below first (useful for ubuntu minimal container)
```sh
sudo apt update -y
sudo apt install -y --no-install-recommends ca-certificates curl
```
Otherwise, directly type in below
```sh
curl -sfL 'https://raw.githubusercontent.com/zaky-jp/playground/main/ubuntu/minimal.sh' | bash -
source ~/.bashrc
```
This does minimalistic bootstrapping including:
 - adding apt mirrors
 - using `doas` for `alias sudo`; and
 - cloning playground directory

# Details into files
## etc/apt
- adding assume-yes
- adding fast mirror (if you are in Japan) except for security

## setup.sh
- adding mDNS service using `avahi-daemon`
- setting appropriate timezone
- installing basic tools like `neovim` `jq`
- execute neccessary `update-alternatives`

## lxd.sh
*Prerequisite*: `lxd`
- create lvm thin-pool within default `ubuntu-vg` volume group
- create macvlan network
- expose lxd for remote management
