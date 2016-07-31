#define _GNU_SOURCE

#include <linux/input.h>

#include <sys/time.h>
#include <sys/types.h>
#include <sys/syscall.h>

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <stdbool.h>

int main() {
    int fd = syscall(SYS_open, "/dev/input/event0", O_RDONLY);
    if (fd < 0) return 1;

    while (true) {
        struct pollfd pollfd;
        pollfd.fd = fd;
        pollfd.events = POLLIN;
        pollfd.revents = 0;
        switch (syscall(SYS_poll, &pollfd, 1, 1)) {
            int n;
            struct input_event ev;
        case -1:
            puts("Error");
            break;
        case 0:
            break;
        case 1:
            n = syscall(SYS_read, fd, &ev, sizeof ev);
            if (n < 0) puts("Error reading");
            if (n != sizeof ev) puts("Read less than size");
            if (ev.type == EV_KEY) {
                if (ev.value == 0) {
                    printf("Release %d\n", ev.code);
                } else if (ev.value == 1) {
                    printf("Press %d\n", ev.code);
                }
            }
            break;
        default:
            puts("How did you get here?");
            break;
        }
    }

    syscall(SYS_close, fd);
    return 0;
}
