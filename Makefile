TestImage.out: test_image.s random.o bmp.o
	gcc -nostdlib -o $@ $^ -g

%.o: %.s
	gcc -nostdlib -c $< -g

clean:
	rm -f *.o
	rm -f TestImage.out
