# capabilities
Intriduced in 1999 / linux 2.2 to split root into units of privilege. Before that administrative actions were performed using root (uid 0) user, sudo command or setting applications suid bit and changing owner to root (they were run with effective uid of owner). It is worth noticing that most of applications require none capabilities, file permisions should be enought - they should be required only for special/administrative tasks.
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
## files capabilities
File can have set suid - if it is owned by root it after `execve()` it will run with euid 0 and have all capabilities set.

We are able to assigne capabilities to file using `setcap 'cap_name+{i,p,e}' ./binary`, where:
* i (inheritable set) - reduces permitted set after `execve()'
* p (permitted set) - adds to permitted set after `execve()'
* e (effective bit) - sets effective set using permitted set after `execve()`, it nof set effective set will be empty [should be used mostly for caps unaware applications]

If application is not aware of it we can add effective bit to binary that will make all permisive info effective without need to calling `setcap()` and eg modifying program code to do that.

Permitted set after `execve()` will be build using inheritable set from parent process, reduced of inheritable set of executable and extended of permitted set of executable.

## fork/execve
On `fork()`/`clone()` capabilities are copied from parent process. On `execve()` process gets all capabilities if process euid is 0 or application has suid bit set and owned by root.
Other wise child process gets copy of inheritable and ambient sets, effective and permitted sets are filled using copy of ambient set.

## libcap
`setcap / getcap` - modify/inspect capabilities for files eg. `setcap cap_sys_admin+ep ./bin`
`pscap` - iterate over `/proc/<pid>` and calls `capget()` 

## docker
Docker sets only selected caps for containers (`CapBnd:	00000000a80425fb`). It is possible to modify container caps using `--cap-add` and `--cap-drop`.
Starting docker as not run user will make it drop all capabilities: 
```bash
$ docker run --user 1000:1000 -it --rm alpine id && cat /proc/self/status | grep CapEff
uid=1000 gid=1000
CapEff:	000000ffffffffff
```
