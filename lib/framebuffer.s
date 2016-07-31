.globl map_framebuffer
.globl unmap_framebuffer
.text

FIX_SIZE = 0x44
MEMLEN_OFF = 0x14
FBIOGET_FSCREENINFO = 0x4602
FBIOGET_VSCREENINFO = 0x4600

VAR_SIZE = 0xA0
XRES_OFF = 0x0
YRES_OFF = 0x4

O_RDWR = 0x2

PROT_READ = 0x1
PROT_WRITE = 0x2
MAP_SHARED = 0x1

SYS_open = 0x05
SYS_close = 0x06
SYS_ioctl = 0x36
SYS_munmap = 0x5B
SYS_mmap2 = 0xC0

/*
==[ FRAMEBUFFER ]======================================
*/
map_framebuffer:
	push	{r4, r5, r6, r7, r8, r9, r10}
	sub	sp, #FIX_SIZE + VAR_SIZE

	// fb_fd = open(fb0, O_RDWR)
	ldr	r0, =fb0
	mov	r1, #O_RDWR
	mov	r7, #SYS_open
	svc	#0
	blt	fail
	mov	r6, r0

	// ioctl(fb_fd, FBIOGET_FSCREENINFO, &fix_info)
	// mov	r0, r6 // redundant
	ldr	r1, =FBIOGET_FSCREENINFO
	sub	r2, sp, #FIX_SIZE + VAR_SIZE
	mov	r7, #SYS_ioctl
	svc	#0
	blt	cleanup

	// Extract the memory size from the struct
	ldr	r8, [sp, #-FIX_SIZE - VAR_SIZE + MEMLEN_OFF]

	// ioctl(fb_fd, FBIOGET_VSCREENINFO, &var_info)
	mov	r0, r6
	mov	r1, #FBIOGET_VSCREENINFO
	sub	r2, sp, #VAR_SIZE
	mov	r7, #SYS_ioctl
	svc	#0
	blt	cleanup

	// Extract the width and height of the screen
	ldr	r9, [sp, #-VAR_SIZE + XRES_OFF]
	ldr	r10, [sp, #-VAR_SIZE + YRES_OFF]

        // mmap(0, length, PROT_READ | PROT_WRITE,
	// 	MAP_SHARED, fbfd, 0)
	mov	r0, #0
	mov	r1, r8
	mov	r2, #PROT_READ | PROT_WRITE
	mov	r3, #MAP_SHARED
	mov	r4, r6
	mov	r5, #0
	mov	r7, #SYS_mmap2
	svc	#0
	blt	cleanup
	mov	r5, r0

	// close(fb_fd)
	mov	r0, r6
	mov	r7, #SYS_close
	svc	#0

	// return fb, size, width, height
	mov	r0, r5
	mov	r1, r8
	mov	r2, r9
	mov	r3, r10
	add	sp, #FIX_SIZE + VAR_SIZE
	pop	{r4, r5, r6, r7, r8, r9, r10}
	mov	pc, lr
cleanup:
	mov	r0, r6
	mov	r7, #SYS_close
	svc	#0
fail:
	mov	r0, #0
	add	sp, #FIX_SIZE + VAR_SIZE
	pop	{r4, r5, r6, r7, r8, r9, r10}
	mov	pc, lr

/*
This routine closes the resources associated with the
framebuffer. It takes the pointer to the mmap'd buffer
in r0 and the length of the buffer in r1.
*/
unmap_framebuffer:
	mov	r2, r7
	// munmap(r0, r1)
	mov	r7, #SYS_munmap
	svc	#0
	mov	r7, r2
	mov	pc, lr

.data
fb0:	.asciz	"/dev/fb0"
