%.o: %.asm
	nasm -felf64 -o $@ $<

all: main.o
	ld main.o -o webs

.PHONY:	clean
clean:
	rm *.o webs
