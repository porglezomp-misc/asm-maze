DUMMY:=$(shell mkdir -p obj target)

all: target/test-fb target/test-image target/fb-example \
	target/values target/shuffle target/test-line \
	target/absdiff target/sleep

target/sleep: src/sleep.s
	gcc -nostdlib -o $@ $^ -g

target/test-line: src/test-line.s obj/line.o obj/framebuffer.o obj/random.o
	gcc -nostdlib -o $@ $^ -g

target/shuffle: src/shuffle.s obj/framebuffer.o obj/hex.o
	gcc -nostdlib -o $@ $^ -g

target/test-fb: src/test-fb.s obj/framebuffer.o obj/random.o obj/hex.o
	gcc -nostdlib -o $@ $^ -g

target/test-image: src/test-bmp.s obj/random.o obj/bmp.o
	gcc -nostdlib -o $@ $^ -g

target/fb-example: experiment/fb-example.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

target/values: experiment/values.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

target/absdiff: experiment/absdiff.s obj/hex.o
	gcc -nostdlib -o $@ $^ -g

obj/%.o: lib/%.s
	gcc -nostdlib -c -o $@ $< -g

clean:
	rm -f target/* obj/*
