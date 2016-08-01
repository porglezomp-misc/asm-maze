	.text

// @Performance: These routines could all make fewer syscalls

	.arm
	.align
	.globl print_nibble
print_nibble:
	mov r3, r7 		// We can save with registers!
				
	and r0, r0, #0xF	// Only print the first 4 bits
	ldr r1, =hexdigits
	add r1, r0, r1

	mov r0, #0
	mov r2, #1
	mov r7, #4
	swi #0

	mov r7, r3
	mov pc, lr


	.arm
	.align
	.globl print_byte
print_byte:
	push {r4, lr}
	mov r4, r0

	lsr r0, r4, #4		// Byte 2
	bl print_nibble
	mov r0, r4
	bl print_nibble
	
	pop {r4, pc}


	.arm
	.align
	.globl print_half
print_half:	
	push {r4, lr}
	mov r4, r0

	lsr r0, r4, #12		// Byte 1
	bl print_nibble
	lsr r0, r4, #8
	bl print_nibble
	lsr r0, r4, #4		// Byte 2
	bl print_nibble
	mov r0, r4
	bl print_nibble

	pop {r4, pc}


	.arm
	.align
	.globl print_word
print_word:
	push {r4, lr}
	mov r4, r0

	lsr r0, r4, #28		// Byte 1
	bl print_nibble
	lsr r0, r4, #24
	bl print_nibble
	lsr r0, r4, #20		// Byte 2
	bl print_nibble
	lsr r0, r4, #16
	bl print_nibble
	lsr r0, r4, #12		// Byte 3
	bl print_nibble
	lsr r0, r4, #8
	bl print_nibble
	lsr r0, r4, #4		// Byte 4
	bl print_nibble
	mov r0, r4
	bl print_nibble

	pop {r4, pc}
	

	.arm
	.align
	.globl newline
newline:
	mov r3, r7
	
	mov r0, #0
	ldr r1, =newline_char
	mov r2, #1
	mov r7, #4
	svc #0

	mov r7, r3
	mov pc, lr


	.data
hexdigits:
	.ascii "0123456789ABCDEF"
newline_char:
	.ascii "\n"
