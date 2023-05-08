@echo off
rem
rem Windows makefile
rem
rem clunky, but does the job. 
rem borrowed some better ideas from 4cade make, thanks qkumba
rem
rem Variables
setlocal enabledelayedexpansion

rem Build stuff
SET AC=build\ac.jar
SET CA65=ca65
SET LD65=ld65
SET BOOTLOADER=build\bootloader.py
SET PYTHON=C:\python27\python.exe

rem disk images
SET OUTPUTDISK1=disks\prodos.po
SET OUTPUTDISK2=disks\prodos_with_loader.po
SET OUTPUTDISK3=disks\prodos_fn.po

if "%1" equ "build" (
call :md
call :build
goto :EOF
)

if "%1" equ "clean" (
:clean
echo y|1>nul 2>nul rd lst /s
echo y|1>nul 2>nul rd obj /s
echo y|1>nul 2>nul rd out /s
goto :EOF
)

echo usage: %0 clean / build
goto :EOF

:md
2>nul md lst
2>nul md obj
2>nul md out
goto :EOF

rem Assemble Boot Loader and a3a2fileemu
:build
%CA65% src/bootloader.s -l lst/bootloader.lst -o obj/bootloader.o
%LD65% obj/bootloader.o -o out/bootloader.bin -C build/apple3bs.cfg
%CA65% src/bootloader_fn.s -l lst/bootloader_fn.lst -o obj/bootloader_fn.o
%LD65% obj/bootloader_fn.o -o out/bootloader_fn.bin -C build/apple3bs.cfg
1>nul %PYTHON% %BOOTLOADER% out\bootloader.bin %OUTPUTDISK1%
1>nul %PYTHON% %BOOTLOADER% out\bootloader.bin %OUTPUTDISK2%
1>nul %PYTHON% %BOOTLOADER% out\bootloader_fn.bin %OUTPUTDISK3%
%CA65% src/a3a2fileemu.s -l lst/a3a2fileemu.lst -o obj/a3a2fileemu.o
%LD65% obj/a3a2fileemu.o -o out/a3a2fileemu.bin -C build/apple3.cfg
java -jar %AC% -d %OUTPUTDISK1% SOS.KERNEL
java -jar %AC% -p %OUTPUTDISK1% SOS.KERNEL SYS $1E00 < out/a3a2fileemu.bin
java -jar %AC% -d %OUTPUTDISK2% SOS.KERNEL
java -jar %AC% -p %OUTPUTDISK2% SOS.KERNEL SYS $1E00 < out/a3a2fileemu.bin
java -jar %AC% -d %OUTPUTDISK3% A3A2FILEEMU
java -jar %AC% -p %OUTPUTDISK3% A3A2FILEEMU SYS $1E00 < out/a3a2fileemu.bin
goto :EOF

