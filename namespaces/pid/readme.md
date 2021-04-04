# pid namespace
Crerating/moving process into pid namespace make kernel to comunicate with proccess using separate set of process identifiers (via calls like `wait()`, `kill()`, `getpid()`, ...). 
This is the only namespace that when calling `unshare()` and `setns()` process is not moved into this namespace. Onle its child processes will be started in it. This is because lot of applications rely on process id being constant during process live time (even glib `getpid()` caches pid and make syscall only once).

## example
```c
#define _GNU_SOURCE
#include <sched.h> // CLONE_NEWPID
#include <unistd.h> // fork, getpid
#include <sys/wait.h> // wait
#include <stdio.h> // printf

int main(int argc, char *argv[]) {
    printf("getpid(): %ld\n", (long) getpid());
    printf("unshare(): %ld\n", (long) unshare(CLONE_NEWPID));
    int p = fork();
    printf("fork(): %d, getpid(): %d\n", p, getpid());
    if (p > 0) {wait(NULL);}
}
```
## /proc/ and pid namespace
Tools like `ps` and `top` reads process information from procfs mounted at `/proc`. It needs to be remounted to be able to see process struct inside on new namespace. This can be done using `chroot` or mount namespace (we need to call `unshare` with `--fork` because process that calls unshare stays in same pid namespace, only child processess will be spawned in namespace - several processes are started and terminated in between and namespace lacks process 1 - fork returns `ENOMEM` error).
```bash
$ unshare --fork --pid --mount
$ umount -l /proc; mount -t proc proc /proc
$ ps
    PID TTY          TIME CMD
      1 pts/1    00:00:00 bash
     12 pts/1    00:00:00 ps
```
# init proccess
First process started in namespace - using `clone(NEW_NSPID)` or `fork()` by process that called `unshare()` or `setns()` besomes namespace init process (pid 1). This make it:
* recieve `SIGCHLD` of all orphant processes in namespace
* processes in namespace are not allowed to send signals to it
* if it recieved `SIGKILL` from outside of namespace it is being terminated and all processes in its namespace receives `SIGKILL`
