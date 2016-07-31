TestFB.out: test_framebuffer.s framebuffer.o
	gcc -nostdlib -o $@ $^

TestImage.out: test_image.s random.o bmp.o
	gcc -nostdlib -o $@ $^ -g

framebuffer-example.out: framebuffer-example.c
	gcc -std=c11 -o $@ $< -Wall -Werror -Wextra -pedantic

sizetest.out: size.c
	gcc -std=c11 -o $@ $<

%.o: %.s
	gcc -nostdlib -c $< -g

clean:
	rm -f *.o *.out
