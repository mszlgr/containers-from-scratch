# Mount (mnt / CLONE_NEWNS)
It was first kernel namespace introduced (2.4.19 in 2002), that is why flag for it is just `CLONE_NEWNS`. 

This namespace isolates lists of mounted points. When new mnt namespace is created it receives copy of mount point list form process that called `clone()` or `unshare()` to create new mnt namespace. After that each call to `mount()` and `umount()` modifies only this namespace mount points list.

## bind mount
`mount --bind a/ b/` mounts dir/file under different location (same inodes). It is possible to bind mount over not empty directory, when umounted original content is returned. Opposite to hard linking bind mounts are kernel not fs objects.

## mount propagation
Mount events in one namespace can be propagated into different namespaces.
