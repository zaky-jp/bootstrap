# microceph
## Prerequisite
- lxd
- unpartitioned disks (may need to `fdisk` and remove partition if label is already set)


## Instruction
First create lxd container using ```${PLAYGROUND_DIR}/ceph/spawn.zsh```. This will set up a container with single node ceph.

### Dashboard password
Dashboard password needs to be manually set. Create temporary password using below command *inside container*:
```
password=$(openssl rand -base64 12 | fold -w 10 | head -1)
echo $password > /tmp/password.txt
ceph dashboard ac-user-create --pwd_update_required ceph_admin -i /tmp/password.txt administrator
```
Then, access ```ip a``` address at port 8080.

### Adding disks
Follow [official guide](https://github.com/canonical/microceph#%EF%B8%8F-adding-osds-and-rgw) to add disks.
