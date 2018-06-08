	.text

POLLFD_SIZE = 0x8
POLLFD_FD_OFF = 0x0
POLLFD_EV_OFF = 0x4

EVENT_SIZE = 0x10
EVENT_TYPE_OFF = 0x8
EVENT_CODE_OFF = 0xA
EVENT_VALUE_OFF = 0xC

POLLIN = 0x1
EV_KEY = 0x1

O_RDONLY = 0x0

SYS_read = 0x3
SYS_open = 0x5
SYS_close = 0x6
SYS_ioctl = 0x36
SYS_poll = 0xA8

	.arm
	.align
	.globl kbd_open
kbd_open:
	push	{r4, r5, r7}

	// The keyboard event selector
	mov	r4, #'0'
	ldr	r5, =kbd_polls

kbd_open_loop:
	ldr	r0, =kbd_path
	// Set the last character of the string
	str	r4, [r0, #kbd_idx_off]
	mov	r1, #O_RDONLY
	mov	r7, #SYS_open
	svc	#0

	// There was an error opening the file
	cmp	r0, #0
	blt	kbd_open_continue

	// Store the file descriptor into the .fd field
	str	r0, [r5, #4]!
	// This stores POLLIN, 0 into the .event, .revent
	mov	r0, #POLLIN
	str	r0, [r5, #4]!

kbd_open_continue:
	add	r4, #1
	cmp	r4, #'9'
	ble	kbd_open_loop

kbd_open_exit:
	// numfds = (end - begin) / 8
	// We don't have to adjust for the 4 bytes of length
	// since we're pre-incrementing above, which leaves us
	// pointing at the end of the last field instead of past
	// the end of the field.
	ldr	r4, =kbd_polls
	sub	r5, r4
	// Return the number of opened file descriptors
	asr	r0, r5, #3
	// Store that number at the beginning of the array
	str	r0, [r4]
	pop	{r4, r5, r7}
	mov	pc, lr

/*
// If we want to print a message later...
kbd_msg:
	.ascii	"no kbd\n"
kdb_msg_len = . - kbd_msg
*/


	.arm
	.align
	.globl kbd_close
kbd_close:
	push	{r4, r5, r7}

	ldr	r4, =kbd_polls
	ldr	r5, [r4], #4
	add	r5, r4, r5, LSL #3

kbd_close_loop:
	ldr	r0, [r4], #8
	mov	r7, #SYS_close
	svc	#0

	cmp	r4, r5
	ble	kbd_close_loop

	pop	{r4, r7}
	mov	pc, lr


	.arm
	.align
	.globl kbd_poll
kbd_poll:
	push	{r4-r7}
	sub	sp, #EVENT_SIZE

	// Read until no file descriptors are ready
readloop:
	// Get the array of keyboard file descriptors
	ldr	r4, =kbd_polls
	// Read the length
	ldr	r5, [r4], #4
	// end = begin + length * 8
	add	r6, r4, r5, LSL #3

	// poll(&kbd_polls, kbd_poll_len, 0)
	mov	r0, r4
	mov	r1, r5
	mov	r2, #0
	mov	r7, #SYS_poll
	svc	#0
	cmp	r0, #0
	ble	done

	// Loop over all of the fds
fdloop:
	// read(fd, &ev, sizeof ev)
	ldr	r0, [r4], #4
	// But first, check if this fd has data
	ldr	r1, [r4], #4
	tst	r1, #POLLIN << 16
	beq	fdloop_continue

	mov	r1, sp
	mov	r2, #EVENT_SIZE
	mov	r7, #SYS_read
	svc	#0
	cmp	r0, #EVENT_SIZE
	bne	done

	// Skip non-key events
	ldrh	r0, [sp, #EVENT_TYPE_OFF]
	cmp	r0, #EV_KEY
	bne	readloop
	// Store the value (pressed status) into the slot
	ldrb	r0, [sp, #EVENT_VALUE_OFF]
	ldrb	r1, [sp, #EVENT_CODE_OFF]
	ldr	r2, =kbd_keys
	strb	r0, [r2, r1]
	
fdloop_continue:
	cmp	r4, r6
	blt	fdloop

	b	readloop
	
done:
	add	sp, #EVENT_SIZE
	pop	{r4-r7}
	mov	pc, lr


	.data

kbd_path:
	.asciz	"/dev/input/eventN"
kbd_idx_off = 16


	.bss
/*
kbd_keys is a global array of booleans, if an entry is
one that key is pressed, if it's zero then it's not.
*/
	.globl kbd_keys
kbd_keys:
	.zero	256

/*
kbd_polls is an array of pollfd structs.
The first 4 bytes store the count, then the next 10 8-byte
segments are all pollfd entries.
*/
kbd_polls:
	.zero 4 + 10 * POLLFD_SIZE

