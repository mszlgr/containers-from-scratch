#define _GNU_SOURCE
#include <sys/utsname.h> // uname
#include <sched.h> // clone, CLONE_NEWUTS
#include <sys/wait.h> // wait
#include <unistd.h> // sethostname
#include <stdio.h> // printf

static char child_stack[10240];
int childFunc(void *arg) {
    struct utsname uts;
    sethostname("modified-by-child", 17);
    uname(&uts); printf("child hostname(): %s\n", uts.nodename);
}

int main(int argc, char *argv[]) {
    struct utsname uts;
    uname(&uts); printf("parent hostname(): %s\n", uts.nodename);
    int child_pid = clone(childFunc, child_stack + 10240, CLONE_NEWUTS | SIGCHLD, NULL);
    wait(NULL);
    uname(&uts); printf("parent hostname(): %s\n", uts.nodename);
}
