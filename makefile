DUMMY:=$(shell mkdir -p obj target)

ASM=gcc -nostdlib -o $@ $^ -g
C=gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

all: target/test-fb target/test-image target/fb-example \
	target/values target/shuffle target/test-line \
	target/absdiff target/sleep target/wiggler \
	target/textmode target/graphicsmode

target/wiggler: src/wiggler.s obj/framebuffer.o obj/line.o
	${ASM}

target/sleep: src/sleep.s
	${ASM}

target/test-line: src/test-line.s obj/line.o obj/framebuffer.o obj/random.o
	${ASM}

target/shuffle: src/shuffle.s obj/framebuffer.o obj/hex.o
	${ASM}

target/test-fb: src/test-fb.s obj/framebuffer.o obj/random.o obj/hex.o
	${ASM}

target/test-image: src/test-bmp.s obj/random.o obj/bmp.o
	${ASM}

target/absdiff: experiment/absdiff.s obj/hex.o
	${ASM}

target/graphicsmode: experiment/graphicsmode.c
	${C}

target/textmode: experiment/textmode.c
	${C}

target/fb-example: experiment/fb-example.c
	${C}

target/values: experiment/values.c
	${C}

obj/%.o: lib/%.s
	gcc -nostdlib -c -o $@ $< -g

clean:
	rm -f target/* obj/*
