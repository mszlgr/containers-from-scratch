# network namespaces
Network namespaces provide separation of whole networking stack, network interfaces, iptable rules...

## interfaces
Physical interface can live only in one namespace. When one that it is in is destroyed it will be moved to initial network namespace.

Virtual interfaces when namespace is destroyed are also destroyed (with existign paired interface that was in stil existing namespace). 

## ip netns
`ip netns list` - `open("/var/run/netns")` and lists all namespaces + socket communication with ???

`ip netns add netns` - `open("/var/run/netns/netns", O_RDONLY|O_CREAT|O_EXCL, 000)` + `unshare(CLONE_NEWNET)` + `mount("/proc/self/ns/net", "/var/run/netns/netns"...)`

`ip netns exec newns bash` - `openat(AT_FDCWD, "/run/netns/newns", O_RDONLY|O_CLOEXEC)` + `setns(5, CLONE_NEWNET)` + `execve("/usr/bin/bash", ...)`

## docker
Docker creates ns links in `/var/run/docker/netns`. To use them with `ip netns` we need to mount them in `/var/run/netns`, where they are expected by `ip netns`.
```
docker_ns_path=$(docker inspect -f '{{.NetworkSettings.SandboxKey}}' 5e5fb43af81a)
ln -s $docker_ns_path /var/run/netns/docker_ns   or    mount --bind $docker_ns_path /var/run/netns/docker_ns # TODO - this works only once for given ns - not able to add again same ns
ip netns exec docker_ns bash
ip netns exec docker_ns ip -4 a
```
