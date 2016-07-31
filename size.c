#include <linux/fb.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>

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
    print_int(FBIOGET_VSCREENINFO);
    puts("");
    print_int(O_RDWR);
    puts("");
    print_int(PROT_READ);
    print_int(PROT_WRITE);
    print_int(MAP_SHARED);
    return 0;
}
