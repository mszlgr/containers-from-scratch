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
