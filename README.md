# containers-from-scratch
Containers is a technology that allows isolating processes running on one operating system. This is achieved with:
* **namespaces** to isolate processes
* **cgroups** to manage resources like cpu and memory
* **capabilities** and **seccomp** used to increase secuirty
* **overlay filesystems** to optimize disk space utilization

Tools like docker are creating and managing metadata about those to build containers on top of that.

```bash
# starting namespace
$ unshare --fork --user --uts --pid --net --mount --ipc --map-root-user
$ # networking setup
$ pivot_root ./rootfs ./rootfs/old
$ cd /
$ umount /old
$ mount -t proc proc /proc

# entering namespace
$ cd /proc/<pid>/ns
$ nsenter --uts=./uts --user=./user --mount=./mnt --net=./net --ipc=./ipc --pid=./pid --utc=./utc # or $ nsenter -t <pid> -Umnipu

```

# runc spec
When calling `docker run alpine` docker cli sends request to containerd what manages images and prepares `rootfs` and `config.json` for `runc`. As an example of real world container runtime [`runc` spec can be checked](https://github.com/opencontainers/runc/blob/master/libcontainer/SPEC.md)
```bash
$ mkdir -p ./rootfs && docker export $(docker create alpine) | tar -C rootfs -xf -
$ strace -f runc run containername 2>&1 | grep -e pivot -e execv -e unshare -e mount\( -e clone -e umount
execve("/usr/sbin/runc", ["runc", "run", "abc"], 0x7ffeeee3bc28 /* 35 vars */) = 0
[pid  8476] execve("/proc/self/exe", ["runc", "init"], 0xc0000847d0 /* 8 vars */ <unfinished ...>
[pid  8476] <... execve resumed>)       = 0
[pid  8476] mount("/proc/self/exe", "/run/user/1000/runc/abc/runc.ram5n6", 0x8b4b69, MS_BIND, 0x8b4b69 <unfinished ...>
[pid  8476] execveat(7, "", ["runc", "init"], 0xe3f2e0 /* 9 vars */, AT_EMPTY_PATH) = 0
[pid  8477] unshare(CLONE_NEWUSER)      = 0
[pid  8477] unshare(CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWPID) = 0
[pid  8477] clone(child_stack=0x7ffe10d22ec0, flags=CLONE_PARENT|SIGCHLD) = 8478
[pid  8478] mount("", "/", 0xc00012444c, MS_REC|MS_SLAVE, NULL) = 0
[pid  8478] mount("/home/marek/rootfs", "/home/marek/rootfs", 0xc0001248fa, MS_BIND|MS_REC, NULL) = 0
[pid  8478] mount("proc", "/home/marek/rootfs/proc", "proc", 0, NULL) = 0
[pid  8478] mount("tmpfs", "/home/marek/rootfs/dev", "tmpfs", MS_NOSUID|MS_STRICTATIME, "mode=755,size=65536k") = 0
[pid  8478] mount("devpts", "/home/marek/rootfs/dev/pts", "devpts", MS_NOSUID|MS_NOEXEC, "newinstance,ptmxmode=0666,mode=0"...) = 0
...
[pid  8478] mount("/dev/null", "/home/marek/rootfs/dev/null", 0xc000124bba, MS_BIND, NULL) = 0
[pid  8478] mount("/dev/random", "/home/marek/rootfs/dev/random", 0xc000124bc8, MS_BIND, NULL) = 0
[pid  8478] mount("/dev/full", "/home/marek/rootfs/dev/full", 0xc000124be8, MS_BIND, NULL) = 0
[pid  8478] mount("/dev/tty", "/home/marek/rootfs/dev/tty", 0xc000124c08, MS_BIND, NULL) = 0
[pid  8478] mount("/dev/zero", "/home/marek/rootfs/dev/zero", 0xc000124c28, MS_BIND, NULL) = 0
[pid  8478] mount("/dev/urandom", "/home/marek/rootfs/dev/urandom", 0xc000124c48, MS_BIND, NULL) = 0
[pid  8478] pivot_root(".", ".")        = 0
[pid  8478] mount("", ".", 0xc000124d44, MS_REC|MS_SLAVE, NULL) = 0
[pid  8478] umount2(".", MNT_DETACH)    = 0
...
[pid  8478] execve("/bin/sh", ["sh"], 0xc000120940 /* 3 vars */ <unfinished ...>
```
