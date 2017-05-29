	.text

GIGA = 1000000000
NS_PER_FRAME = GIGA/30
ESC = 1

UP = 103
LEFT = 105
RIGHT = 106
DOWN = 108

X = 0
Y = 4
ANGLE = 8
CLOCK = 12

	.globl	_start
_start:
	sub	sp, #4
	mov	r0, sp
	bl	clock_init

	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res
	bl	graphics_mode
	bl	fb_map
	bl	kbd_open

	ldr	r4, =kbd_keys

	mov	r0, #192 << 10
	mov	r1, #120 << 10
	mov	r2, #0
	push	{r0, r1, r2}

mainloop:
update:
	bl	kbd_poll

	ldr	r9, [sp, #ANGLE]

	ldrb	r0, [r4, #LEFT]
	cmp	r0, #0
	addne	r9, #-64
	ldrb	r0, [r4, #RIGHT]
	cmp	r0, #0
	addne	r9, #64

	ldr	r10, [sp, #X]
	ldr	r11, [sp, #Y]

	mov	r0, r9
	bl	icos12
	asr	r5, r0, #2
	mov	r0, r9
	bl	isin12
	asr	r6, r0, #2

	mov	r7, #0
	ldrb	r0, [r4, #UP]
	cmp	r0, #0
	addne	r7, #1
	ldrb	r0, [r4, #DOWN]
	cmp	r0, #0
	addne	r7, #-1

	mla	r10, r7, r5, r10
	mla	r11, r7, r6, r11

	str	r9, [sp, #ANGLE]
	str	r10, [sp, #X]
	str	r11, [sp, #Y]

draw:
	mov	r0, #0
	bl	fb_clear_color

	ldr	r12, =-512
drawloop:
	add	r0, r9, r12
	bl	icos12
	mov	r10, r0
	add	r0, r9, r12
	bl	isin12
	mov	r11, r0

	ldr	r0, [sp, #X]
	asr	r0, #10
	ldr	r1, [sp, #Y]
	asr	r1, #10
	add	r2, r0, r10, ASR #7
	add	r3, r1, r11, ASR #7
 	bl	draw_line

	add	r12, #256
	cmp	r12, #512
	ble	drawloop

sleep:
	add	r0, sp, #CLOCK
	mov	r1, #0
	ldr	r2, =NS_PER_FRAME
	bl	clock_inctime

	add	r0, sp, #CLOCK
	bl	clock_sleep
	
esc:
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
