	.text

GIGA = 1000000000
NS_PER_FRAME = GIGA/30
ESC = 1

	.globl _start
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
	ldr	r11, =map
mainloop:
update:
	bl	kbd_poll
draw:
	mov	r0, #0
	bl	fb_clear_color

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

sleep:
	mov	r0, sp
	mov	r1, #0
	ldr	r2, =NS_PER_FRAME
	bl	clock_inctime

	mov	r0, sp
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
