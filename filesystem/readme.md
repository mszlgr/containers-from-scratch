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
`pivot_root()` modify whole mnt namespace, when `chroot()` only process and its childrens. There are subtel bugs that would allow jailbreaks from `chroot()` - eg. if `chroot()` is called from subsequent process and not pid 1 `chroot /proc/1/root` can be used to run away back to old filesystem.

`chroot()` - calls [kernel](https://github.com/torvalds/linux/blob/fcadab740480e0e0e9fa9bd272acd409884d431a/fs/fs_struct.c#L15) `set_fs_root(current->fs, &path);` it only updates `struct path root` for process. Current working directory allows access to old root, any link or mount from new root to old also.

```bash
unshare --mount
pivot_root newdir newdir/olddir
umount /olddir
rmdir /olddir
```

## overlay filesystem
```bash
mount -t overlay overlay -o lowerdir=/lower2:/lower1,upperdir=/upper,workdir=/work /merged
```
lowerdir - base directories, layered in order, mounted as read-only. Last in list is lowest laye.r
upperdir - top layer, if writeable changes are added here. File removal from lower layers is handled by adding char device with zero size.
workdir - must be empty



## dumping docker image fs
Running docker image can be dumped using:
```bash
$ mkdir ./img
$ docker export $(docker run -d alpine sleep 1) | tar -x  --directory ./img/ --
```
 

## docker
Image layers are managed by docker. Using layers it expose only rootfs to runc as a last layer. [RunC only finds mount given root fs](https://github.com/opencontainers/runc/blob/b23315bdd99c388f5d0dd3616188729c5a97484a/libcontainer/rootfs_linux.go#L749). In addition docker injects `/etc/hosts`, `/etc/hostname` and `/etc/resolv.conf`:
```bash
$ ls /var/lib/docker/containers/<hash>/
660724167c3fbf880c969e8c6e66c52b26baf586eb73901204da41ef23176597-json.log
config.v2.json
hostname
hosts
resolv.conf
mounts/
```
Logfile contain whole container stdout. Hostname file contains short container hash id, hosts mapping for this hostname and localhost.

### docker mounts list:
What container have mounted on startup:
```bash
docker run --rm alpine mount
overlay on / type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/l/2SQTNARNPDB5OQ5B4JZRO6P6RC:/var/lib/docker/overlay2/l/KNGKLZKSKQDUVHVACXKJK32HSE,upperdir=/var/lib/docker/overlay2/b3ab618014d8a0145bce61414521a80dbd4a0156ca8953481628ce96f90130c6/diff,workdir=/var/lib/docker/overlay2/b3ab618014d8a0145bce61414521a80dbd4a0156ca8953481628ce96f90130c6/work)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev type tmpfs (rw,nosuid,size=65536k,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=666)
sysfs on /sys type sysfs (ro,nosuid,nodev,noexec,relatime)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (ro,nosuid,nodev,noexec,relatime,xattr,name=systemd)
...
```

### docker (containerd/runc) strace:
```bash
unshare(CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|CLONE_NEWPID)
clone(...)
...
mount("/var/lib/docker/overlay2/17454fba32dff0215c4a1af8575ad2a17e3b8f7fb478ae59b2d9ab57ffdd6dbf/merged", "/var/lib/docker/overlay2/17454fba32dff0215c4a1af8575ad2a17e3b8f7fb478ae59b2d9ab57ffdd6dbf/merged", 0xc00015dcca, MS_BIND|MS_REC, NULL) = 0
...
mount("/var/lib/docker/containers/7860e8e3213145cf766761bc23aec77f79a46c1b733d5c0c1a5ff4b44d0b1d9e/hosts", "/var/lib/docker/overlay2/17454fba32dff0215c4a1af8575ad2a17e3b8f7fb478ae59b2d9ab57ffdd6dbf/merged/etc/hosts", ...)
[same for hostname and resolv.conf, id in path is container id)
...
mount("proc", "/var/lib/docker/overlay2/17454fba32dff0215c4a1af8575ad2a17e3b8f7fb478ae59b2d9ab57ffdd6dbf/merged/proc")
...
openat(AT_FDCWD, "/") = 6
openat(AT_FDCWD, "/var/lib/docker/overlay2/17454fba32dff0215c4a1af8575ad2a17e3b8f7fb478ae59b2d9ab57ffdd6dbf/merged") = 8
fchdir(8)
pivot_root(".", ".")
fchdir(6)
mount("", ".")
chdir("/)
...
sethostname("7860e8e32131", 12)
...
```
Image is passed as options (lowerdir) in top most mount call in listing. Images are stored in `/var/lib/docker/image/overlay2/imagedb/content/sha256/`
When we have access to `/var/lib/docker/overlay2/<MergedDirID>/merge/` we have access to top layer.
