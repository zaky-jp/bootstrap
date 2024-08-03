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
bash <(curl -sSfL 'https://raw.githubusercontent.com/zaky-jp/playground/main/ubuntu/minimal.sh')
```
Or, on non-interactive instance (like inside docker)
```sh
bash <(curl -sSfL 'https://raw.githubusercontent.com/zaky-jp/playground/main/ubuntu/minimal.sh') --noninteractive-instance
```
This does minimalistic bootstrapping including:
 - adding minimal apt config
 - adding apt mirrors
 - upgrading to latest software

# Details into files
## etc/netplan
- network config template under lxd

## server.sh
- adding mDNS service using `avahi-daemon`
- setting appropriate timezone
- installing basic tools like `neovim` `jq`
- execute neccessary `update-alternatives`

## lxd.sh
*Prerequisite*: `lxd`
- create lvm thin-pool within default `ubuntu-vg` volume group
- create macvlan network
- expose lxd for remote management

## spawn-minimal.sh
- Creating an instance inside lxd
