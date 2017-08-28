	.text

GIGA = 1000000000
NS_PER_FRAME = GIGA/30

ESC = 1
UP = 103
LEFT = 105
RIGHT = 106
DOWN = 108

	.globl _start
_start:
	bl	random_seed_dev
	sub	sp, #0x3D0
	mov	r0, sp
	mov	r1, #31
	mov	r2, #31
	bl	maze_gen

	sub	sp, #8
	mov	r0, sp
	bl	clock_init

	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res
	bl	graphics_mode
	bl	fb_map
	bl	kbd_open

	add	r0, sp, #8
	mov	r1, #16
	mov	r2, #16
	bl	tr_set_env

	kb_base	.req r4
	ldr	kb_base, =kbd_keys

mainloop:
update:
	bl	kbd_poll

draw:
	mov	r0, #0
	bl	fb_clear_color

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
