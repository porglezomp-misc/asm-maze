.globl _start

_start:
	bl	map_framebuffer
	mov	r4, r0
	mov	r5, r1
	mov	r0, r4
	mov	r1, r5
	bl	unmap_framebuffer

done:
	mov	r0, #0
	mov	r7, #1
	svc	#0
