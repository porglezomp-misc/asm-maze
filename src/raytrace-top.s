	.text

GIGA = 1000000000
NS_PER_FRAME = GIGA/30

ESC = 1
UP = 103
LEFT = 105
RIGHT = 106
DOWN = 108

	.globl	_start
_start:
	sub	sp, #8
	mov	r0, sp
	bl	clock_init

	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res
	bl	graphics_mode
	bl	fb_map
	bl	kbd_open

	ldr	r0, =map
	mov	r1, #16
	mov	r2, #16
	bl	tr_set_env

	kb_base	.req r4
	ldr	kb_base, =kbd_keys
	ldr	r11, =map
	mov	r9, #260
	mov	r10, #260

mainloop:
update:
	bl	kbd_poll

	mov	r5, r10
	ldrb	r0, [kb_base, #UP]
	cmp	r0, #0
	addne	r10, #-64
	ldrb	r0, [kb_base, #DOWN]
	cmp	r0, #0
	addne	r10, #64

	mov	r5, r9
	ldrb	r0, [kb_base, #LEFT]
	cmp	r0, #0
	addne	r9, #-64
	ldrb	r0, [kb_base, #RIGHT]
	cmp	r0, #0
	addne	r9, #64

draw:
	mov	r0, #0
	bl	fb_clear_color

	mov	r2, #8
	add	r0, r2, r9, LSR #5
	add	r1, r2, r10, LSR #5
	mov	r2, #20
	mov	r3, #20
	bl	draw_line

	mov	r5, #0xFF
drawloop:
	ldrb	r6, [r11, r5]
	cmp	r6, #0
	beq	loopstep

	mov	r2, #8
	and	r0, r5, #0xF
	add	r0, r2, r0, LSL #3
	lsr	r1, r5, #4
	add	r1, r2, r1, LSL #3
	mov	r3, #8
	bl	draw_rect

loopstep:
	subs	r5, #1
	bpl	drawloop

trace:
	mov	r0, #0xFF
	bl	rect_set_color

	mov	r0, #(256 + 128) << 4
	mov	r1, #(256 + 128) << 4
	lsl	r2, r9, #4
	lsl	r3, r10, #4
	bl	tr_trace_block
	cmp	r2, #0
	mov	r2, #8
	add	r0, r2, r0, ASR #9
	add	r1, r2, r1, ASR #9
	mov	r2, #8
	mov	r3, #8
	blne	draw_rect

	mvn	r0, #0
	bl	rect_set_color

sleep:
	mov	r0, sp
	mov	r1, #0
	ldr	r2, =NS_PER_FRAME
	bl	clock_inctime

	mov	r0, sp
	bl	clock_sleep
	
esc:
	ldrb	r0, [kb_base, #ESC]
	cmp	r0, #0
	beq	mainloop

	.unreq	kb_base

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
map:
	.byte	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	.byte	1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1
	.byte	1,0,1,1,0,1,0,1,0,1,0,1,1,1,0,1
	.byte	1,0,1,0,0,0,0,1,0,1,0,0,0,1,0,1
	.byte	1,0,1,0,1,1,0,1,0,1,1,1,0,0,0,1
	.byte	1,0,1,0,1,0,0,0,0,0,0,1,1,1,1,1
	.byte	1,0,0,0,1,0,1,1,0,1,0,0,0,0,0,1
	.byte	1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,1
	.byte	1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1
	.byte	1,0,1,0,0,0,1,1,0,0,0,1,0,1,0,1
	.byte	1,0,1,1,0,1,0,1,1,1,0,1,0,1,0,1
	.byte	1,0,1,0,0,0,0,0,0,1,0,0,0,1,0,1
	.byte	1,0,1,0,1,1,0,1,0,1,1,1,0,0,0,1
	.byte	1,0,1,0,0,1,0,1,0,1,0,1,1,1,0,1
	.byte	1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1
	.byte	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
