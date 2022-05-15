config:
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
  raw.lxc: lxc.mount.auto=proc:rw sys:rw
  security.privileged: "true"
  security.nesting: "true"
  security.syscalls.intercept.mknod: "true"
  security.syscalls.intercept.setxattr: "true"
# vim: set filetype=yaml :
