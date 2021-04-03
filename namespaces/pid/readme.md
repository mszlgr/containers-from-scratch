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
