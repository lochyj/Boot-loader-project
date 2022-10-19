# $@ = target file
# $< = first dependency
# $^ = all dependencies

C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h  drivers/*.h)
OBJ_FILES = ${C_SOURCES:.c=.o}

# First rule is the one executed when no parameters are fed to the Makefile
all: run

kernel.bin: bootloader/kernel-entry.o ${OBJ_FILES}
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

os-image.bin: mbr.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=$<
# qemu-system-x86_64 -fda $<

%.o: %.c ${HEADERS}
	x86_64-elf-gcc -g -m32 -ffreestanding -c $< -o $@ # -g for debugging

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

%.dis: %.bin
	ndisasm -b 32 $< > $@

clean:
	$(RM) *.bin *.o *.dis