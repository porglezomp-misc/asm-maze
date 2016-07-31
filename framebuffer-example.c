#define _GNU_SOURCE
#include <linux/fb.h>

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#include <sys/types.h>

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

const char *FB_NAME = "/dev/fb0";

int main() {
    int status = 0;
    int fbfd = syscall(SYS_open, FB_NAME, O_RDWR, 0);
    // int fbfd = open(FB_NAME, O_RDWR);
    if (fbfd < 0) {
        printf("Unable to open %s.\n", FB_NAME);
        return 1;
    }

    struct fb_fix_screeninfo fix_info;
    // if (ioctl(fbfd, FBIOGET_FSCREENINFO, &fix_info) < 0) {
    if (syscall(SYS_ioctl, fbfd, FBIOGET_FSCREENINFO, &fix_info) < 0) {
        printf("Failed to get fixed screen info: %s\n", strerror(errno));
        syscall(SYS_close, fbfd);
        return 1;
    }

    struct fb_var_screeninfo var_info;
    //if (ioctl(fbfd, FBIOGET_VSCREENINFO, &var_info) < 0) {
    if (syscall(SYS_ioctl, fbfd, FBIOGET_VSCREENINFO, &var_info) < 0) {
        printf("Failed to get variable screen info: %s\n", strerror(errno));
        syscall(SYS_close, fbfd);
        return 1;
    }

    int length = fix_info.smem_len;
    printf("Line length: %d\n", fix_info.line_length);
    printf("Mem length: %d\n", fix_info.smem_len);
    printf("Resolution: %dx%d\n", var_info.xres, var_info.yres);

    void *framebuffer = (void*)syscall(
        // mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
        SYS_mmap2, 0, length, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    // close(fbfd);
    syscall(SYS_close, fbfd);
    if (framebuffer == NULL) {
        printf("mmap failed.\n");
        return 1;
    }

    short *p = framebuffer;
    for (size_t y = 0; y < var_info.yres; y += 2) {
        for (size_t  x = 0; x < var_info.xres; x += 2) {
            size_t a0 = x + y * var_info.xres;
            size_t a1 = x + (y+1) * var_info.xres;
            short avg = (p[a0] + p[a0+1] + p[a1] + p[a1+1])/4;
            p[a0] = p[a0+1] = p[a1] = p[a1+1] = avg;
        }
    }

    // munmap(framebuffer, length);
    syscall(SYS_munmap, framebuffer, length);
    return status;
}
