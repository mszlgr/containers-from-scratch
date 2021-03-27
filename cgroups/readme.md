## cgroups
Each process needs to be be in one and only one of each cgroup type. Process inherits cgroups from parent process. Process can switch any cgroup type by being added to `/sys/fs/cgropu/<type>/<group name>/tasks` file.

```echo $$ > /sys/fs/cgroup/cpu/A/tasks```

Kernel interface for managing cgroups is exposed using sysfs:

```
/sys/fs/cgroup/* 
[blkio, cpu,cpuacct, cpuset, devices, freezer, hugetlb, memory, net_cls, net_prio, perf_event, pids, rdma]
```

Checking what cgroups process is part of:

```cat /proc/$$/cgroup```

Any cgroup parameter may be modified by writing values to proper gropu config files, eg:

```echo 256 > /sys/fs/cgroup/cpu/A/cpu.shares```

## libcgroup - TODO add more info
cgroups can be managed using `cgroup-tools` utils and `libcgroup`:
* cgcreate/cgdelete/cgclear -> cgcreate -g cpu:A - mkdir /sys/fs/cgroup/cpu/A and kernel creates dir with all required files inside
* cgset/cgget -> cgget -g cpu:A - reads all /sys/fs/cgroup/cpu/A/*
* cgexec/cgclassify
* lscgroups -> reads /sys/fs

## TODO add descriptions of most useful gropus/parameters
