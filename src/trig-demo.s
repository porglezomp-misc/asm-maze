	.text

NS_PER_FRAME = 1000000000/30
ESC = 1

.macro line x0 y0 x1 y1
mov	r0, \x0
mov	r1, \y0
mov	r2, \x1
mov	r3, \y1
bl	draw_line
.endm

	.globl _start
_start:
	sub	sp, #4 * 6

	add	r0, sp, #4 * 4
	bl	clock_init

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

	mov	r11, #0
mainloop:
update:
	add	r11, #64
	bl	kbd_poll
draw:
	mov	r0, #0
	bl	clear_color

	mov	r5, #0
	mov	r7, #8
	mov	r8, #0
	mov	r10, #0

	add	r0, r11, r5, LSL #6
	bl	isin12
	asr	r6, r0, #6
	rsb	r6, #120

	add	r0, r11, r5, LSL #6
	bl	icos12
	asr	r9, r0, #6
	rsb	r9, #120
drawloop:
	lsl	r0, r7, #6
	add	r0, r11
	bl	isin12
	asr	r8, r0, #6
	rsb	r8, #120

	lsl	r0, r7, #6
	add	r0, r11
	bl	icos12
	asr	r10, r0, #6
	rsb	r10, #120

	line	r5, r6, r7, r8
	line	r5, r9, r7, r10
	
	mov	r6, r8
	mov	r9, r10
	add	r5, #8
	add	r7, #8
	cmp	r7, #384
	blt	drawloop

sleep:
	add	r0, sp, #4 * 4
	mov	r1, #0
	ldr	r2, =NS_PER_FRAME
	bl	clock_inctime

	add	r0, sp, #4 * 4
	bl	clock_sleep

	ldrb	r0, [r4, #ESC]
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
