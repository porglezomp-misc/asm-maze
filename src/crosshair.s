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

UP = 103
LEFT = 105
RIGHT = 106
DOWN = 108

.macro line x0 y0 x1 y1
mov	r0, \x0
mov	r1, \y0
mov	r2, \x1
mov	r3, \y1
bl	draw_line
.endm

.macro clamp reg min max
cmp	\reg, \min
movlt	\reg, \min
cmp	\reg, \max
movgt	\reg, \max
.endm

_start:
	sub	sp, #4 * 6
	// Setup the clock
	mov	r0, #CLOCK_MONOTONIC
	add	r1, sp, #4 * 4
	ldr	r7, =SYS_clock_gettime
	svc	#0

	mov	r0, #384
	mov	r1, #240
	bl	set_resolution

	bl	graphics_mode

	bl	map_framebuffer
	str	r1, [sp, #4 * 3]
	str	r2, [sp, #4 * 2]
	str	r3, [sp, #4 * 1]
	str	r0, [sp]

	bl	kbd_open

	ldr	r4, =kbd_keys
	mov	r5, #192
	mov	r6, #120
	ldr	r8, =383
	
mainloop:
inctime:
	ldr	r0, [sp, #4 * 4]	// seconds
	ldr	r1, [sp, #4 * 5]	// nanoseconds

	// Increment time by one frame
	ldr	r2, =NS_PER_FRAME
	add	r1, r2
	ldr	r2, =GIGA
	// Handle nanosecond overflow
	cmp	r1, r2
	subge	r1, r2
	addge	r0, #1

	// Restore the timespec
	str	r0, [sp, #4 * 4]
	str	r1, [sp, #4 * 5]

update:
	bl	kbd_poll

	.macro motion reg key dist
	ldrb	r0, [r4, \key]
	cmp	r0, #0
	addne	\reg, \dist
	.endm

	motion	r5, #LEFT, #-1
	motion	r5, #RIGHT, #1
	motion	r6, #UP, #-1
	motion	r6, #DOWN, #1

	clamp	r5, #72, #312
	clamp	r6, #0, #240

draw:
	mov	r0, #0
	bl	clear_color

	line	#0, #0, r5, r6
	line	r8, #0, r5, r6
	line	r8, #239, r5, r6
	line	#0, #239, r5, r6

sleep:
	// Sleep until the next frame
	mov	r0, #CLOCK_MONOTONIC
	mov	r1, #TIMER_ABSTIME
	add	r2, sp, #4 * 4
	mov	r3, #0
	ldr	r7, =SYS_clock_nanosleep
	svc	#0
	// Continue interrupted sleeps
	cmp	r0, #0
	blt	sleep

	ldrb	r0, [r4, #1]	// escape
	cmp	r0, #0
	beq	mainloop

done:
	ldr	r0, [sp]
	ldr	r1, [sp, #4 * 3]
	bl	unmap_framebuffer

	bl	kbd_close
	bl	text_mode

	ldr	r0, =1680
	ldr	r1, =1050
	bl	set_resolution

	mov	r0, #0
	mov	r7, #1
	svc	#0
