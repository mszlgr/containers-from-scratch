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
