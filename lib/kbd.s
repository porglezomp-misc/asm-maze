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
SYS_poll = 0xA8

	.arm
	.align
	.globl kbd_open
kbd_open:
	mov	r2, r7

	ldr	r1, =kbd_keys

# @Todo: Handle checking keyboard capabilities
	ldr	r0, =kbd_path
	mov	r1, #O_RDONLY
	mov	r7, #SYS_open
	svc	#0

	ldr	r1, =kbd_fd
	str	r0, [r1]

	mov	r7, r2
	mov	pc, lr


	.arm
	.align
	.globl kbd_close
kbd_close:
	mov	r2, r7

	ldr	r1, =kbd_fd
	ldr	r0, [r1]
	mov	r7, #SYS_close
	svc	#0

	mov	r7, r2
	mov	pc, lr


	.arm
	.align
	.globl kbd_poll
kbd_poll:
	push	{r7}
	sub	sp, #POLLFD_SIZE + EVENT_SIZE
	ldr	r3, =kbd_fd
	ldr	r3, [r3]

readloop:
	// Zero out the pollfd struct
	str	r3, [sp, #POLLFD_FD_OFF]
	// This stores POLLIN, 0 into the .event, .revent
	mov	r0, #POLLIN
	str	r0, [sp, #POLLFD_EV_OFF]

	// poll(&pollfd, 1, 1)
	mov	r0, sp
	mov	r1, #1
	mov	r2, #1
	mov	r7, #SYS_poll
	svc	#0
	cmp	r0, #0
	ble	done

	// read(fd, &ev, sizeof ev)
	mov	r0, r3
	add	r1, sp, #POLLFD_SIZE
	mov	r2, #EVENT_SIZE
	mov	r7, #SYS_read
	svc	#0
	cmp	r0, #EVENT_SIZE
	bne	done

	// Skip non-key events
	ldrh	r0, [sp, #POLLFD_SIZE + EVENT_TYPE_OFF]
	cmp	r0, #EV_KEY
	bne	readloop
	// Store the value (pressed status) into the slot
	ldrb	r0, [sp, #POLLFD_SIZE + EVENT_VALUE_OFF]
	ldrb	r1, [sp, #POLLFD_SIZE + EVENT_CODE_OFF]
	ldr	r2, =kbd_keys
	strb	r0, [r2, r1]

	b	readloop
	
done:
	add	sp, #POLLFD_SIZE + EVENT_SIZE
	pop	{r7}
	mov	pc, lr


	.data

kbd_path:
	.asciz	"/dev/input/eventN"
kbd_idx_off = 16
kbd_msg:
	.ascii	"no kbd\n"
kdb_msg_len = . - kbd_msg
kbd_fd:
	.word	-1


	.bss
/*
kbd_keys is a global array of booleans, if an entry is
one that key is pressed, if it's zero then it's not.
*/
	.align
	.globl kbd_keys
kbd_keys:
	.zero	256


