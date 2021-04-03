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
