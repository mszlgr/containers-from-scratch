# pid namespace
Crerating pid namespace require root/CAP_SYS_ADMIN. 

clone()
```
#define _GNU_SOURCE
#include <sched.h> // clone, CLONE_NEWPID
#include <unistd.h> // getpid
#include <sys/wait.h> // wait
#include <stdio.h> // printf

static char child_stack[10240];
int childFunc(void *arg) {printf("PID child: %ld\n", (long) getpid());}

int main(int argc, char *argv[]) {
    int child_pid = clone(childFunc, child_stack + 10240, CLONE_NEWPID | SIGCHLD, NULL);
    printf("PID returned by clone(): %ld\n", (long) child_pid);
    wait(NULL);
}
```

unshare() + fork()
```
#define _GNU_SOURCE
#include <sched.h> // CLONE_NEWPID
#include <unistd.h> // fork, getpid
#include <sys/wait.h> // wait
#include <stdio.h> // printf

int main(int argc, char *argv[]) {
    printf("getpid(): %ld\n", (long) getpid());
    int p = fork();
    printf("fork(): %d, getpid(): %d\n", p, getpid());
    if (p == 0) {return 0;} else { wait(NULL);}

    printf("unshare(): %ld\n", (long) unshare(CLONE_NEWPID));
    p = fork();
    printf("fork(): %d, getpid(): %d\n", p, getpid());
    if (p > 0) {wait(NULL);}
}
```
