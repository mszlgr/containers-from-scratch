# user namespace
This namespace isolated values returned by `getuid()`, `geteuid()`, `getgid()` and `getegid()`. This is the only namespace that do not require root/CAP_SYS_ADMIN.
Every process run in each namespace maps to one real user on host. If user namespace is started and non-privileged user is being mapped to root (uid 0) it can still eg. write to files owned by root. Unmapped user id is verified kernel side before performing requested actions.

Mapping between user in and outside namespace is required, if non process is started with default uid set in `/proc/sys/kernel/overflowuid` and gid from `/proc/sys/kernel/overflowgid`. Defaut value in those files is 65534 which maps to `/etc/passwd` user `nobody`.


## user mappings
if we have running process in namespace we can set mapping for it `user-ids-in-ns user-ids-that-started-ns ids-cnt`, eg:.
```bash
[shell 1]$ id
uid=1000(user) gid=1000(user)
[shell 1]$ unshare -U
[shell 1]$ id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
[shell 1]$ echo $$
18935
...
[shell 2]$ echo '0 1000 1' > /proc/18935/uid_map
...
[shell 1]$ id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
uid=0(root) gid=65534(nogroup) groups=65534(nogroup)
```

`unshare --user --map-root-user` will create user namespace with root user. Under the hood it sets proper mappings:
```bash
$ strace unshare -Ur
...
unshare(CLONE_NEWUSER)                  = 0
openat(AT_FDCWD, "/proc/self/setgroups", O_WRONLY) = 3
write(3, "deny", 4)                     = 4
close(3)                                = 0
openat(AT_FDCWD, "/proc/self/uid_map", O_WRONLY) = 3
write(3, "0 1000 1", 8)                 = 8
close(3)                                = 0
openat(AT_FDCWD, "/proc/self/gid_map", O_WRONLY) = 3
write(3, "0 1000 1", 8)                 = 8
close(3)                                = 0
execve("/bin/bash", ["-bash"], 0x7ffe7cfe2940 /* 35 vars */) = 0
...
```

## setting user mappings
`/proc/<pid>/uid_map` and `/proc/<pid>/gid_map` are owned by user that created users namespace. They are writable only by that user or privileged user.

If process want to set user mappings in need to do it before calling `execve()`. That is because when a process with non-zero user IDs performs an `execve()`, the process's capability sets are cleared.
In effect even calling `unshare -U` as a root we are not able to modify own `/proc/self/uid_map` because we are runnign as 65534 (default from `/proc/sys/kernel/overflowuid`) and we lost all capabilities.
