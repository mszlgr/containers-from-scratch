# containers-from-scratch

```bash
# starting namespace
$ unshare --fork --user --uts --pid --net --mount --ipc --map-root-user
$ mount -t proc proc /proc
$ # TODO set networking
$ # TODO create copy of namespaces

# entering namespace
$ cd /proc/<pid>/ns
$ nsenter --uts=./uts --user=./user --mount=./mnt --net=./net --ipc=./ipc --pid=./pid

```
