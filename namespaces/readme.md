# Linux namespaces
Namespace lives only if there is any reference to it inode. On process creation links to all process namespaces are created in `/proc/<pid>/ns/{mnt,net,pid,uts,ipc,user,cgroup}`.
Processes inherits namespaces from parent on `fork()`, on `clone()` it is possible to pass flags that would cause kernel to create new namespace of required type for new process.

Syscalls involved in namespaces management:
`clone(..., int flags, ...)` - creates new process/thread in separate namespace

`int unshare(int flags)` - for existing process creates new namespace(s) of given types eg. `unshare(CLONE_NEWPID | CLONE_NEWUSER)`

` int setns(int fd, int nstype)` - for existing process switch it namespace using given file descriptor (eg taken from `/prod/<other_pid>/ns/`). `nstype` can be passed to make kernel side check if given fd is pointing to correct namesapce type. If `0` not check is performed. 

`clone()`/`unshare()`/`setns()` flags:
* `mnt` - `CLONE_NEWNS`
* `net` - `CLONE_NEWNET`
* `pid` - `CLONE_NEWPID`
* `uts` - `CLONE_NEWUTS`
* `ipc` - `CLONE_NEWIPC`
* `user` - `CLONE_NEWUSER`
* `cgroup` - `CLONE_NEWCGROUP`


## shell utils
`lsns` - iterates over `/proc/<pid>` and runs `stat()` on `ns/{mnt,net,pid,uts,ipc,user,cgroup}` to get inode that is a kernel handle and namespace identifier.

`unshare ` - calls `unshare(ns)` where ns is list of passed namespaces and after that `execve()` with command passed

`nsenter` - calls `setns()` using given namespace files descriptors - eg. `nsenter --uts=/proc/123/ns/uts` or it can lookup proc path using just PID `nsenter --target=123 --uts`

## required privileges
Creating all but user namespace require running process with effective root or setting `CAP_SYS_ADMIN` capability.

`sudo ./a.out` or `sudo setcap 'cap_sys_admin+ep' ./a.out; ./a.out`

## user namespace and other namespaces
User namespace is only namespace that do not require to be created by privileged user, any user can create new user namespace. Critical part of understaning namespace security model is that each namespace belongs to one user namesapce. When actions is performed in given namespace eg. interface is added in net namespace or host modified in uts namespace - [kernel checks if this process is capable to perform this action based on process uid in reference to owning user namespace](https://elixir.bootlin.com/linux/v5.10/source/kernel/capability.c#L396).
* [linux v5.10 utsname.h](https://elixir.bootlin.com/linux/v5.10/source/include/linux/utsname.h#L27)
```c
struct uts_namespace {
	struct kref kref;
	struct new_utsname name;
	struct user_namespace *user_ns;
  ...
```
* [linux v5.10 ipc_namespace.h](https://elixir.bootlin.com/linux/v5.10/source/include/linux/ipc_namespace.h#L68)
```c
struct ipc_namespace {
	refcount_t	count;
  ...
	/* user_ns which owns the ipc ns */
	struct user_namespace *user_ns;
  ...
```

## joining namespace / exec
```bash
$ hostname main; uname -n
main
$ unshare --uts
$ hostname modified; uname -n
modified
$ touch /tmp/uts; mount --bind /proc/$$/ns/uts /tmp/uts
$ exit
$ uname -n
main
$ nsenter --uts=/tmp/uts; uname -n
modified
$ unmount /tmp/uts
```

When we run `docker exec` in shell `docker cli` is sending http request to `dockerd` which then sends grpc request to `containerd-shim` which calls `runc`
```bash
$ docker exec 9523c27424e4 ls
...
$ strace -f -p $(pidof containerd-shim) 2>&1 | grep -e openat -e setns -e execve
...
execve("/usr/sbin/runc", ["runc", "--root", "/var/run/docker/runtime-runc/mob"...
...
openat(AT_FDCWD, "/proc/13294/ns/mnt", O_RDONLY) = 12
...
setns(12, CLONE_NEWNS)      = 0
...
execve("/bin/ls", ["ls"], 0xc000157ba0 /* 3 vars */ <unfinished ...>
...
```
