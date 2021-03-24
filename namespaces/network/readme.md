##
`ip netns list` - `open("/var/run/netns")` and lists all namespaces + socket communication with ???

`ip netns add newns` - `open("/var/run/netns/newns", O_RDONLY|O_CREAT|O_EXCL, 000)` + `unshare(CLONE_NEWNET)` + `mount("/proc/self/ns/net", "/var/run/netns/ns1"...)`

# interfaces
Physical interface can live only in one namespace. When one that it is in is destroyed it will be moved to initial network namespace.

Virtual interfaces when namespace is destroyed are also destroyed (with existign paired interface that was in stil existing namespace). 
