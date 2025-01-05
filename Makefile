# Makefile for a3a2fileemu
AC = build/ac.jar
BOOTLOADER = build/bootloader.py
OUTPUTDISK1 = disks/prodos.po
OUTPUTDISK2 = disks/prodos_with_loader.po
OUTPUTDISK3 = disks/prodos_fn.po

default:
	mkdir -p lst
	mkdir -p obj
	mkdir -p out
	ca65 src/bootloader.s -l lst/bootloader.lst -o obj/bootloader.o
	ld65 obj/bootloader.o -o out/bootloader.bin -C build/apple3bs.cfg
	ca65 src/bootloader_fn.s -l lst/bootloader_fn.lst -o obj/bootloader_fn.o
	ld65 obj/bootloader_fn.o -o out/bootloader_fn.bin -C build/apple3bs.cfg
	$(BOOTLOADER) out/bootloader.bin $(OUTPUTDISK1)
	$(BOOTLOADER) out/bootloader.bin $(OUTPUTDISK2)
	$(BOOTLOADER) out/bootloader_fn.bin $(OUTPUTDISK3)
	ca65 src/a3a2fileemu.s -l lst/a3a2fileemu.lst -o obj/a3a2fileemu.o
	ld65 obj/a3a2fileemu.o -o out/a3a2fileemu.bin -C build/apple3.cfg
	java -jar $(AC) -d $(OUTPUTDISK1) SOS.KERNEL
	java -jar $(AC) -p $(OUTPUTDISK1) SOS.KERNEL SYS 0x1E00 < out/a3a2fileemu.bin
	java -jar $(AC) -d $(OUTPUTDISK2) SOS.KERNEL
	java -jar $(AC) -p $(OUTPUTDISK2) SOS.KERNEL SYS 0x1E00 < out/a3a2fileemu.bin
	java -jar $(AC) -d $(OUTPUTDISK3) A3A2EMU
	java -jar $(AC) -p $(OUTPUTDISK3) A3A2EMU SYS 0x1E00 < out/a3a2fileemu.bin

clean:
	rm -r lst
	rm -r obj
	rm -r out
