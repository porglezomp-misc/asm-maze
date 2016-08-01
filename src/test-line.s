        .globl _start
        .text

.macro line x0 y0 x1 y1
mov	r0, \x0
mov	r1, \y0
mov	r2, \x1
mov	r3, \y1
bl	draw_line
.endm

_start:
	mov	r0, #384
	mov	r1, #240
	bl	fb_set_res

	bl	fb_map

        mov     r0, #0
        bl      fb_clear_color

	mov	r10, #32
loop:
	bl	random_word
	and	r4, r0, #0xFF
	bl	random_word
	and	r5, r0, #0x7F
	bl	random_word
	and	r6, r0, #0xFF
	bl	random_word
	and	r7, r0, #0x7F
	
	line	r4, r5, r6, r7

	subs	r10, #1
	bpl	loop

	add	sp, #12

	bl	fb_unmap

	mov	r0, #0
	mov	r7, #1
	svc	#0
