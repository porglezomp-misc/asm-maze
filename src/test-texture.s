	.text

NS_PER_FRAME = 1000000000/30
ESC = 1

	.globl _start
_start:
	sub	sp, #4 * 2

	mov	r0, sp
	bl	clock_init

	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res
	bl	graphics_mode
	bl	fb_map
	bl	kbd_open

	ldr	r4, =kbd_keys

mainloop:
update:
	bl	kbd_poll
draw:
	mov	r0, #0
	bl	fb_clear_color

	ldr	r5, =texture
	.macro	column scol tcol h
	mov	r0, \scol
	mov	r1, \tcol
	mov	r2, \h
	mov	r3, r5
	bl	blit_col
	.endm

	mov	r6, #32
	mov	r7, #0
	mov	r8, #200
	mov	r9, #0
drawloop:
	column	r6, r9, r8
	add	r6, #1
	column	r6, r9, r8
	add	r6, #1
	sub	r8, #2

	add	r7, #2
	asr	r9, r7, #4
	cmp	r9, #4
	blt	drawloop

sleep:
	mov	r0, sp
	mov	r1, #0
	ldr	r2, =NS_PER_FRAME
	bl	clock_inctime

	mov	r0, sp
	bl	clock_sleep

	ldrb	r0, [r4, #ESC]
	cmp	r0, #0
	beq	mainloop

done:
	bl	fb_unmap
	bl	kbd_close
	bl	text_mode

	ldr	r0, =1680
	ldr	r1, =1050
	bl	fb_set_res

	mov	r0, #0
	mov	r7, #1
	svc	#0

	.data
	// Height stored as log2(h), for easier div
	.4byte	3
texture:
	// Pixels stored with columns consecutive
	.2byte	0xF000, 0xFFFF, 0xFFFF, 0xFFFF, 0xF000, 0x0F00, 0x00F0, 0x000F	// col 0
	.2byte	0xFFFF, 0xF000, 0xF000, 0xFFFF, 0x000F, 0xF000, 0x0F00, 0x00F0	// col 1
	.2byte	0xFFFF, 0xF000, 0xF000, 0xFFFF, 0x00F0, 0x000F, 0xF000, 0x0F00	// etc.
	.2byte	0xF000, 0xFFFF, 0xFFFF, 0xFFFF, 0x0F00, 0x00F0, 0x000F, 0xF000
