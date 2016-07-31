#define _POSIX_C_SOURCE 199309L

#include <linux/fb.h>
#include <linux/input.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/kd.h>

#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <time.h>
#include <poll.h>

#define print_sizeof(X) printf("sizeof(" #X "): 0x%x\n", sizeof(X))
#define print_offset(X, M) printf("offsetof(" #X ", " #M "): 0x%x\n", offsetof(X, M))
#define print_int(I) printf(#I ": 0x%x\n", I)

int main() {
    print_sizeof(struct fb_fix_screeninfo);
    print_offset(struct fb_fix_screeninfo, smem_len);
    print_int(FBIOGET_FSCREENINFO);
    puts("");

    print_sizeof(struct fb_var_screeninfo);
    print_offset(struct fb_var_screeninfo, xres);
    print_offset(struct fb_var_screeninfo, yres);
    print_offset(struct fb_var_screeninfo, xres_virtual);
    print_offset(struct fb_var_screeninfo, yres_virtual);
    print_int(FBIOGET_VSCREENINFO);
    print_int(FBIOPUT_VSCREENINFO);
    puts("");

    print_int(O_RDWR);
    print_int(O_RDONLY);
    puts("");

    print_int(PROT_READ);
    print_int(PROT_WRITE);
    print_int(MAP_SHARED);
    puts("");

    print_int(SYS_read);
    print_int(SYS_open);
    print_int(SYS_close);
    print_int(SYS_ioctl);
    print_int(SYS_mmap2);
    print_int(SYS_munmap);
    print_int(SYS_nanosleep);
    print_int(SYS_clock_gettime);
    print_int(SYS_clock_nanosleep);
    print_int(SYS_poll);
    puts("");

    print_sizeof(struct timespec);
    print_offset(struct timespec, tv_sec);
    print_offset(struct timespec, tv_nsec);
    print_int(CLOCK_MONOTONIC);
    print_int(TIMER_ABSTIME);
    puts("");

    print_int(KDSETMODE);
    print_int(KD_GRAPHICS);
    print_int(KD_TEXT);
    puts("");

    print_sizeof(struct pollfd);
    print_offset(struct pollfd, fd);
    print_offset(struct pollfd, events);
    print_offset(struct pollfd, revents);
    print_sizeof(struct input_event);
    print_offset(struct input_event, type);
    print_offset(struct input_event, value);
    print_offset(struct input_event, code);
    puts("");

    return 0;
}
