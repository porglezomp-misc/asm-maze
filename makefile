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
	gcc -nostdlib -o $@ $^ -g -Wl,--build-id=none

target/%: experiment/%.s
	gcc -nostdlib -o $@ $^ -g

target/%: experiment/%.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

target/trig-demo: obj/trig.o obj/fb.o obj/clock.o obj/kbd.o \
	obj/line.o
target/test-trig: obj/trig.o obj/hex.o
target/test-texture: obj/blitcol.o obj/fb.o obj/clock.o \
	obj/kbd.o obj/hex.o
target/crosshair: obj/kbd.o obj/fb.o obj/line.o obj/clock.o
target/kbdemo: obj/kbd.o
target/wiggler: obj/fb.o obj/line.o
target/sleep: obj/clock.o
target/test-line: obj/line.o obj/fb.o obj/random.o
target/shuffle: obj/fb.o obj/hex.o
target/test-fb: obj/fb.o obj/random.o obj/hex.o
target/test-bmp: obj/random.o obj/bmp.o
target/absdiff: obj/hex.o

strip: all
	@echo "BEFORE"
	du -hb target/*
	for f in target/*; do strip -s -R .ARM* $$f; done
	@echo "AFTER"
	du -hb target/*

clean:
	rm -f target/* obj/*
