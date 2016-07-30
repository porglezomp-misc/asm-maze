TestImage.out: test_image.s random.o bmp.o
	gcc -nostdlib -o $@ $^ -g

framebuffer-example.out: framebuffer-example.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

%.o: %.s
	gcc -nostdlib -c $< -g

clean:
	rm -f *.o TestImage.out framebuffer-example.out
