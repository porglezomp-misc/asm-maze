#include <linux/fb.h>

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include <sys/types.h>

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

const char *FB_NAME = "/dev/fb0";

int main() {
    int fbfd = open(FB_NAME, O_RDWR);
    if (fbfd < 0) {
        printf("Unable to open %s.\n", FB_NAME);
        return 1;
    }

    struct fb_fix_screeninfo fix_info;
    if (ioctl(fbfd, FBIOGET_FSCREENINFO, &fix_info) < 0) {
        printf("Failed to get fixed screen info: %s\n", strerror(errno));
        close(fbfd);
        return 1;
    }

    struct fb_var_screeninfo var_info;
    if (ioctl(fbfd, FBIOGET_VSCREENINFO, &var_info) < 0) {
        printf("Faield to get variable screen info: %s\n", strerror(errno));
        close(fbfd);
        return 1;
    }

    int length = fix_info.smem_len;
    printf("Line length: %d\n", fix_info.line_length);

    void *framebuffer =
        mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (framebuffer == NULL) {
        printf("mmap failed.\n");
        close(fbfd);
        return 1;
    }

    int *p = framebuffer;
    for (int y = 0; y < var_info.yres; y += 2) {
        for (int  x = 0; x < var_info.xres; x += 2) {
            int a = p[x + y * var_info.xres];
            p[x + y * var_info.xres] = p[x + 1 + y * var_info.xres];
            p[x + 1 + y * var_info.xres] = a;
        }
    }

    munmap(framebuffer, length);
    close(fbfd);
}
