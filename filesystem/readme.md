# file system


``` bash
$ strace -p $(pidof containerd) -f 2>&1 | grep -e CLONE_NEW -e pivot_root -e overlay2 -e execve
[pid  2859] execve("/usr/sbin/runc", ["runc", "--root", "/var/run/docker/runtime-runc/mob"..., "--log", "/run/containerd/io.containerd.ru"..., "--log-format", "json", "start", "a51ea5c27ebc154d5b1be1ee94349e45"...],
...
[pid  2264] unshare(CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|CLONE_NEWPID) = 0
[pid  2264] clone(child_stack=0x7ffc9873a310, flags=CLONE_PARENT|SIGCHLD <unfinished ...>
[pid  2256] <... nanosleep resumed>NULL) = 0
...
[pid  2365] openat(AT_FDCWD, "/var/lib/docker/overlay2/df90539a0d4c7e5ca05a683a97bf75a5495dbb503afb55730ffddd4eb23c7727/merged", O_RDONLY|O_DIRECTORY <unfinished ...>
[pid  2365] <... openat resumed>)       = 8
[pid  2365] fchdir(8)                   = 0
[pid  2365] pivot_root(".", ".")        = 0
...
```

## pivot_root() vs chroot()
`pivot_root()` modify whole mnt namespace, when `chroot()` only process and its childrens. There are subtel (what/how?) bugs that would allow jailbreaks from `chroot()`.

```bash
unshare --mount
pivot_root newdir newdir/olddir
umount /olddir
rmdir /olddir
```
