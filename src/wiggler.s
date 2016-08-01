.globl _start
.text

SYS_nanosleep = 0xA2
SYS_clock_gettime = 0x107
SYS_clock_nanosleep = 0x109

CLOCK_MONOTONIC = 0x1
TIMER_ABSTIME = 0x1

KILO = 1000
MEGA = 1000000
GIGA = 1000000000

NS_PER_FRAME = GIGA/30

.macro line x0 y0 x1 y1
mov	r0, \x0
mov	r1, \y0
mov	r2, \x1
mov	r3, \y1
bl	draw_line
.endm

_start:
	sub	sp, #4 * 2
	// Setup the clock
	mov	r0, #CLOCK_MONOTONIC
	mov	r1, sp
	ldr	r7, =SYS_clock_gettime
	svc	#0

	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res
	bl	graphics_mode
	bl	fb_map

	mov	r4, #120
mainloop:
inctime:
	ldm	sp, {r0, r1}

	// Increment time by one frame
	ldr	r2, =NS_PER_FRAME
	add	r1, r2
	ldr	r2, =GIGA
	// Handle nanosecond overflow
	cmp	r1, r2
	subge	r1, r2
	addge	r0, #1

	// Restore the timespec
	stm	sp, {r0, r1}

draw:
	mov	r0, #0
	bl	fb_clear_color
	// Pingpong from top and bottom of screen
	and	r5, r4, #0xF
	tst	r4, #0x10
	rsbeq	r5, r5, #0xF
	rsb	r6, r5, #230
	add	r5, #10

	line	#64, r5, #16, r6
	line	#64, r5, #128, r6
	line	#32, r5, #128, r6
	line	#32, r5, #48, r6
	line	#128, r5, #48, r6
	line	#128, r5, #256, r6
	line	#176, r5, #256, r6
	line	#368, r5, #256, r6
	line	#176, r5, #368, r6
	line	#368, r5, #128, r6

sleep:
	// Sleep until the next frame
	mov	r0, #CLOCK_MONOTONIC
	mov	r1, #TIMER_ABSTIME
	mov	r2, sp
	mov	r3, #0
	ldr	r7, =SYS_clock_nanosleep
	svc	#0
	// Continue interrupted sleeps
	cmp	r0, #0
	blt	sleep

	subs	r4, #1
	cmp	r4, #0
	bgt	mainloop

done:
	bl	fb_unmap
	bl	text_mode

	ldr	r0, =1680
	ldr	r1, =1050
	bl	fb_set_res

	mov	r0, #0
	mov	r7, #1
	svc	#0
