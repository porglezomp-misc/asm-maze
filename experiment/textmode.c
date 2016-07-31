#include <sys/types.h>
#include <sys/stat.h>
#include <sys/kd.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <fcntl.h>

int main() {
    int fd = open("/dev/tty", O_RDWR);
    ioctl(fd, KDSETMODE, KD_TEXT);
    close(fd);
    return 0;
}
