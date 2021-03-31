# Mount (mnt / CLONE_NEWNS)
It was first kernel namespace introduced (2.4.19 in 2002), that is why flag for it is just `CLONE_NEWNS`. 

This namespace isolates mount endpoints. When new mnt namespace is created it receives copy of mount point list form process that called `clone()` or `unshare()` to create new mnt namespace.

TOOD:
https://lwn.net/Articles/689856/
https://lwn.net/Articles/531419/#proc_pid
