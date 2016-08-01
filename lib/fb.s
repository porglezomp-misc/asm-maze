.text

FIX_SIZE = 0x44
MEMLEN_OFF = 0x14
FBIOGET_FSCREENINFO = 0x4602
FBIOGET_VSCREENINFO = 0x4600
FBIOPUT_VSCREENINFO = 0x4601

VAR_SIZE = 0xA0
XRES_OFF = 0x0
YRES_OFF = 0x4
XRES_VIRT_OFF = 0x8
YRES_VIRT_OFF = 0xC

O_RDWR = 0x2

PROT_READ = 0x1
PROT_WRITE = 0x2
MAP_SHARED = 0x1

SYS_open = 0x05
SYS_close = 0x06
SYS_ioctl = 0x36
SYS_munmap = 0x5B
SYS_mmap2 = 0xC0

KDSETMODE = 0x4B3A
KD_GRAPHICS = 0x1
KD_TEXT = 0x0

/*
==[ FRAMEBUFFER ]======================================
*/
	.arm
	.align
	.globl fb_map
fb_map:
	push	{r4, r5, r6, r7, r8, r9, r10}
	sub	sp, #FIX_SIZE + VAR_SIZE

	// fb_fd = open(fb0, O_RDWR)
	ldr	r0, =fb0
	mov	r1, #O_RDWR
	mov	r7, #SYS_open
	svc	#0
	cmp	r0, #0
	blt	fail
	mov	r6, r0

	// ioctl(fb_fd, FBIOGET_FSCREENINFO, &fix_info)
	// mov	r0, r6 // redundant
	ldr	r1, =FBIOGET_FSCREENINFO
	mov	r2, sp
	mov	r7, #SYS_ioctl
	svc	#0
	cmp	r0, #0
	blt	cleanup

	// Extract the memory size from the struct
	ldr	r8, [sp, #MEMLEN_OFF]

	// ioctl(fb_fd, FBIOGET_VSCREENINFO, &var_info)
	mov	r0, r6
	mov	r1, #FBIOGET_VSCREENINFO
	add	r2, sp, #FIX_SIZE
	mov	r7, #SYS_ioctl
	svc	#0
	cmp	r0, #0
	blt	cleanup

	// Extract the width and height of the screen
	ldr	r9, [sp, #FIX_SIZE + XRES_OFF]
	ldr	r10, [sp, #FIX_SIZE + YRES_OFF]

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
	cmp	r0, #0
	blt	cleanup
	mov	r5, r0

	// close(fb_fd)
	mov	r0, r6
	mov	r7, #SYS_close
	svc	#0

	// Store the framebuffer parameters
	ldr	r0, =fb_data
	str	r5, [r0, #8]
	str	r8, [r0, #12]
	stm	r0, {r9, r10}
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
This routine unmaps the framebuffer memory.
It takes no arguments.
*/
	.arm
	.align
	.globl fb_unmap
fb_unmap:
	mov	r2, r7
	ldr	r0, =fb_data
	add	r0, #8
	ldm	r0, {r0, r1}
	// munmap(r0, r1)
	mov	r7, #SYS_munmap
	svc	#0
	mov	r7, r2
	mov	pc, lr


/*
This routine attempts to set the resolution to the width
and height specified in r0 and r1, and returns the actual
resolution that the display gets set to. If any operation
fails, it returns the resolution -1, -1.
*/
	.arm
	.align
	.globl fb_set_res
fb_set_res:
	sub	sp, #VAR_SIZE
	push	{r4, r5, r7}
	mov	r4, r0
	mov	r5, r1

	ldr	r0, =fb0
	mov	r1, #O_RDWR
	mov	r7, #SYS_open
	svc	#0
	cmp	r0, #0
	blt	fail_set
	mov	r6, r0

	// ioctl(fb_fd, FBIOGET_VSCREENINFO, &var_info)
	mov	r0, r6
	mov	r1, #FBIOGET_VSCREENINFO
	mov	r2, sp
	mov	r7, #SYS_ioctl
	svc	#0
	cmp	r0, #0
	blt	cleanup_set

	str	r4, [sp, #XRES_OFF]
	str	r5, [sp, #YRES_OFF]
	str	r4, [sp, #XRES_VIRT_OFF]
	str	r5, [sp, #YRES_VIRT_OFF]

	// ioctl(fb_fd, FBIOPUT_VSCREENINFO, &var_info);
	mov	r0, r6
	ldr	r1, =FBIOPUT_VSCREENINFO
	mov	r2, sp
	mov	r7, #SYS_ioctl
	svc	#0
	cmp	r0, #0
	blt	cleanup_set

	// ioctl(fb_fd, FBIOGET_VSCREENINFO, &var_info)
	mov	r0, r6
	mov	r1, #FBIOGET_VSCREENINFO
	mov	r2, sp
	mov	r7, #SYS_ioctl
	svc	#0

	ldr	r0, [sp, #XRES_OFF]
	ldr	r1, [sp, #YRES_OFF]
	add	sp, #VAR_SIZE
	pop	{r4, r5, r7}
	mov	pc, lr

cleanup_set:
	mov	r0, r6
	mov	r7, #SYS_close
	svc	#0

fail_set:
	add	sp, #VAR_SIZE
	pop	{r4, r5, r7}
	mov	r0, #-1
	mov	r1, #-1
	mov	pc, lr


/*
This routine clears the screen to the color specified
in r0, using the same stack arguments as draw_line: the
width, height, and pointer should be passed as stack
arguments.
*/
	.arm
	.align
	.globl fb_clear_color
fb_clear_color:
	// Compute the final offset
	ldr	r3, =fb_data
	ldm	r3, {r1, r2}
	mul	r1, r1, r2
	lsl	r1, #1
	ldr	r2, [r3, #8] 
	sub	r1, #2
	
	// Fill backwards from there
loop:
	strh	r0, [r2, r1]
	subs	r1, #2
	bpl loop

	mov	pc, lr


/*
These routines set the display to graphics or text mode.
*/
	.arm
	.align
	.globl graphics_mode
	.globl text_mode
graphics_mode:
	mov	r12, #KD_GRAPHICS
	b	set_mode
text_mode:
	mov	r12, #KD_TEXT
set_mode:
	push	{r4, r7}
	// fd = open("/dev/tty", O_RDWR)
	ldr	r0, =tty 
	mov	r1, #O_RDWR
	mov	r7, #SYS_open
	svc	#0
	cmp	r0, #0
	blt	set_mode_done
	mov	r4, r0

	// ioctl(fd, KDSETMODE, KD_GRAPHICS)
	// mov	r0, r4
	ldr	r1, =KDSETMODE
	mov	r2, r12
	mov	r7, #SYS_ioctl
	svc	#0

	// close(fd)
	mov	r0, r4
	mov	r7, #SYS_close
	svc	#0
set_mode_done:
	pop	{r4, r7}
	mov	pc, lr


.data
fb0:	.asciz	"/dev/fb0"
tty:	.asciz	"/dev/tty"
.globl fb_data
fb_data:
	.4byte	0 // width
	.4byte	0 // height
	.4byte	0 // pointer
	.4byte	0 // buffer size
