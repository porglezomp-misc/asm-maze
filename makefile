DUMMY:=$(shell mkdir -p obj target)

C_EXP=$(wildcard experiment/*.c)
ASM_EXP=$(wildcard experiment/*.s)
EXP=$(C_EXP:experiment/%.c=target/%) \
	$(ASM_EXP:experiment/%.s=target/%)
SRC=$(wildcard src/*.s)
PROG=$(SRC:src/%.s=target/%)
LIB=$(wildcard lib/*.s)
SIZE=$(LIB:lib/%.s=obj/%.size)

all: $(EXP) $(PROG) $(SIZE)

obj/%.o: lib/%.s
	gcc -nostdlib -c -o $@ $< -g

obj/%.size: src/exit.s obj/%.o
	gcc -nostdlib -o $@ $^ -g -Wl,--build-id=none

target/%: src/%.s
	gcc -nostdlib -o $@ $^ -g -Wl,--build-id=none

target/%: experiment/%.s
	gcc -nostdlib -o $@ $^ -g

target/%: experiment/%.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

target/view-top: obj/fb.o obj/clock.o obj/kbd.o \
	obj/line.o obj/trig.o obj/hex.o
target/raytrace-top: obj/fb.o obj/clock.o obj/kbd.o obj/rect.o \
	obj/raytrace.o obj/line.o
target/maze-top: obj/fb.o obj/clock.o obj/kbd.o obj/rect.o
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
target/maze-dir: obj/fb.o obj/clock.o obj/kbd.o obj/rect.o \
	obj/raytrace.o obj/line.o obj/trig.o obj/random.o \
	obj/maze.o
target/mazegen: obj/bmp.o obj/maze.o obj/random.o obj/hex.o

# Library dependencies
obj/rect.size: obj/fb.o
obj/line.size: obj/fb.o
obj/blitcol.size: obj/fb.o
obj/maze.size: obj/random.o

strip: all
	@echo "========"
	@echo " BEFORE"
	@echo "========"
	du -hb target/*
	for f in target/* obj/*.size; do \
		strip -s -R .ARM* $$f; done
	@echo "======="
	@echo " AFTER"
	@echo "======="
	du -hb target/*

libsize: strip
	@echo "==============="
	@echo " LIBRARY SIZES"
	@echo "==============="
	du -hb obj/*.size

clean:
	rm -f target/* obj/*
