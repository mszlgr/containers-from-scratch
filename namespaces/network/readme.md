##
`ip netns list` - `open("/var/run/netns")` and lists all namespaces + socket communication with ???

`ip netns add newns` - `open("/var/run/netns/newns", O_RDONLY|O_CREAT|O_EXCL, 000)` + `unshare(CLONE_NEWNET)` + `mount("/proc/self/ns/net", "/var/run/netns/ns1"...)`
