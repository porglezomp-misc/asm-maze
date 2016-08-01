DUMMY:=$(shell mkdir -p obj target)

C_EXP=$(wildcard experiment/*.c)
ASM_EXP=$(wildcard experiment/*.s)
EXP=$(C_EXP:experiment/%.c=target/%) \
	$(ASM_EXP:experiment/%.s=target/%)
SRC=$(wildcard src/*.s)
PROG=$(SRC:src/%.s=target/%)

all: $(EXP) $(PROG)

obj/%.o: lib/%.s
	gcc -nostdlib -c -o $@ $< -g

target/%: src/%.s
	gcc -nostdlib -o $@ $^ -g

target/%: experiment/%.s
	gcc -nostdlib -o $@ $^ -g

target/%: experiment/%.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

target/test-texture: obj/blitcol.o obj/framebuffer.o \
	obj/clock.o obj/keyboard.o obj/hex.o
target/crosshair: obj/keyboard.o obj/framebuffer.o \
	obj/line.o obj/clock.o
target/kbdemo: obj/keyboard.o
target/wiggler: obj/framebuffer.o obj/line.o
target/sleep: obj/clock.o
target/test-line: obj/line.o obj/framebuffer.o obj/random.o
target/shuffle: obj/framebuffer.o obj/hex.o
target/test-fb: obj/framebuffer.o obj/random.o obj/hex.o
target/test-bmp: obj/random.o obj/bmp.o
target/absdiff: obj/hex.o

clean:
	rm -f target/* obj/*
