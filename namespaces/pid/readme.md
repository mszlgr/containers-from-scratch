# pid namespace
Crerating/moving process into pid namespace make kernel to comunicate with proccess using separate set of process identifiers (via calls like `wait()`, `kill()`, `getpid()`, ...). 

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
Tools like `ps` and `top` reads process information from procfs mounted at `/proc`. It needs to be remounted to be able to see process struct inside on new namespace. This can be done using `chroot` or mount namespace.
```bash
$ unshare -fork --pid --mnt
$ umount -l /proc; mount -t proc proc /proc
$ ps
    PID TTY          TIME CMD
      1 pts/1    00:00:00 bash
     12 pts/1    00:00:00 ps
```
