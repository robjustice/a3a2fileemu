# Apple3 file based Apple2 Emulation Launcher
This idea started with some thoughts on how to get the Fujinet Config program running easily on the Apple ///. The Fujinet config program is written in C and compiled using CC65. The issue with running this on the A3, is there are no native CC65 libraries available yet for the A3.

The idea I thought about was to create a ProDOS disk with a file based Apple2 emulation launcher. This would setup the A2 emulation environment on the A3 and then bootup ProDOS. We don't have any Language card available on the stock A3, so the only ProDOS available that supports 48k is the original ProDOS 1.0. 48k ProDOS 1.0 loads its Kernel from address $9000 up, so this will limit the memory available for programs. Perhaps another option is to modify the relocation code to move it to one of the spare A3 memory banks, but that's another rabbit hole.

This setup will allow small C programs that are using basic text output to be run ok on either the A2 or A3 from the one disk. Due to ProDOS being loaded from $9000, the standard loader.system file that comes with CC65 assumes Prodos is loaded into the language card and alocates its file buffer on top of ProDOS. I have included a modifed version of it that allocates its buffer to just below the 48k ProDOS.

One thing that is configurable in the a3a2fileemu source file, is enabling full hardware A2 emulation mode, or, running in A3 Funny/Satan mode. To be able to reboot back into the Apple3 mode after running the config program, we must run the emulation in Funny/Satan mode.

Not too sure how much other use this setup will be, and its expanded a bit from the simple idea at the start. Its been an interesting learning exercise though.

## Details
There are two parts to this:
1. Bootloader

This is taken from soshdboot, with some updates/enhancements. It uses the ProDOS/SOS two block dual boot setup.
On an Apple2, the boot loader will load the PRODOS kernel file from either floppy or a Prodos Block mode device
On an Apple3, The boot loader will load the SOS.KERNEL file from either floppy or a Prodos Block mode device(with soshdboot rom)

2. File based Emulation Launcher

This is a file based loader for setting up the emulation environment, it is placed on the disk and named SOS.KERNEL.

Performs the following:
- Load font included in loader, includes lowercase
- Copy Applesoft & Autostart roms included in loader to D000-FFFF
- Copy in Slot roms included in loader to C500-C7FF
- switch in and write protect the A3 system page ram
- Setup - bank=0, zeropage=0, 1Mhz, enable Titan ///+II if installed (gives language card) 
- jump to the Apple2 reset entry point. this will then trigger the boot process again, and boot as per an Apple2, loading ProDOS.

Note: if you have the Titan///+II, then the Prodos1.0 machine detection determines its running on A3 A2emulation, and still loads as a 48k machine. Something to patch later.

## Build
The following tools are used:

  -  ca65 assembler (needs to be in your path)
  -  ld65 linker (needs to be in your path)
  -  Applecommander (included in build folder)
  -  bootloader.py (included in build folder)

There are two options for building, a simple Makefile, or for Windows, the winmake.bat. 

## Pre Built Disks
In the disks folder, the following are provided:
- prodos.po
  
  Includes the updated bootloader, ProDOS 1.0.2 Kernel file, and the A2emu SOS.KERNEL file
  Just replace the bitsy.system with your xx.system file
  
- prodos_with_loader.po
  
  Includes the updated bootloader, ProDOS 1.0.2 Kernel file, and the A2emu SOS.KERNEL file
  This also includes the modified CC65 loader.system file
  Just add your cc65 program and rename the 'loader' name to match your program

- loader.system
  
  This is the modifed loader.system file with the buffer address adjusted for 48k ProDOS

- grafex_example.po
  
  This is an example disk with a CC65 program with a demo for the Grafex card. This was to show how the same program can be run on both environments easily. Its only using simple text output for menus, and then driving the card directly via the slot IO.
  
  This disk can be booted in MAME with the grafex card in slot 1.
  example:
   ```
   mame apple2ee -window -sl1 grafex -flop1 grafex_eample.po
   mame apple2ee -window -sl1 grafex -sl7 cffa2 -hard1 grafex_eample.po
   mame apple3 -window -sl1 grafex -flop1 grafex_eample.po
   mame apple3 -window -sl1 grafex -sl4 cffa2 -hard1 grafex_eample.po -bios 1
   ```
