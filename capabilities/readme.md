# capabilities
Intriduced in 1999 / linux 2.2 to split root into units of privilege. Before that administrative actions were performed using root (uid 0) user, sudo command or setting applications suid bit and changing owner to root (they were run with effective uid of owner).
Kernel when syscall is performed check if running process has effective capability to perform requested action. If application is run as euid 0 then it has all capabilities turned on.
How many caps are supported by given hernel can be checked reading `/proc/sys/kernel/cap_last_cap`.
* effective - set of permisions that will be verified on kernel side
* permitted - caps that can be enabled in effective and inheritable sets
* inheritable - set that will be passed to child processes as their permitted set
* ambient - set that is preserved during `execve()` and used as effective and permitted set
* bounding - limitting superset

Each process caps can be readed from procfs:
```bash
$ cat /proc/self/status | grep Cap
CapInh:	0000000000000000 
CapPrm:	0000000000000000 
CapEff:	0000000000000000
CapBnd:	000000ffffffffff 
CapAmb:	0000000000000000
```
## fork/execve
On `fork()`/`clone()` capabilities are copied from parent process. On `execve()` process gets all capabilities if process euid is 0 or application has suid bit set and owned by root.
Other wise child process gets copy of inheritable and ambient sets, effective and permitted sets are filled using copy of ambient set.

## libcap
`setcap / getcap` - modify/inspect capabilities for files eg. `setcap cap_sys_admin+ep ./bin`
`getpcaps` - 
`pscap` - iterate over `/proc/<pid>` and calls `capget()` 


binaries - inherit / per + effective bit, stored in xattr's
setting `sudo setcap ‘cap_net_raw+p’ ./app` will set it Cap Permited bit, but it need to be aware of capabilities and elevate its effective capabilities (example of such application is ping).
If application is not aware of it we can add effective bit to binary that will make all permisive info effective without need to calling `setcap()` and eg modifying program code to do that.

`P'(effective) = F(effective) ? P'(permitted) : 0`
