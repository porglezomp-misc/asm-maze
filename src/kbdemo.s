	.text

SYS_write = 0x4

STDOUT = 1

UP = 103
LEFT = 105
RIGHT = 106
DOWN = 108

	.globl _start
_start:
	bl	kbd_open

	ldr	r4, =kbd_keys
loop:
	bl	kbd_poll

	mov	r7, #SYS_write
	mov	r2, #1	// 1 character

	.macro pkey offset addr
	ldrb	r0, [r4, \offset]
	cmp	r0, #0
	movne	r0, #STDOUT
	ldrne	r1, =\addr
	svcne	#0
	.endm

	pkey	#UP, up
	pkey	#DOWN, down
	pkey	#LEFT, left
	pkey	#RIGHT, right

	ldrb	r0, [r4, #1]	// escape
	cmp	r0, #0
	beq	loop

done:
	bl	kbd_close

	mov	r0, #0
	mov	r7, #1
	svc	#0

up:	.ascii	"^"
down:	.ascii	"v"
left:	.ascii	"<"
right:	.ascii	">"
