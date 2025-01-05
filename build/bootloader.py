#!/usr/bin/python3
# very basic helper to update boot loader
# RJ
#

import argparse
import os.path

parser = argparse.ArgumentParser(
    prog='bootloader.py',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description='Boot Loader Updater'
)

parser.add_argument("bootloader", help="Boot Loader bin filename")
parser.add_argument("diskimage", help="Disk Image filename to update")
args = parser.parse_args()

ext = os.path.splitext(args.diskimage)
format = ext[1]

with open(args.bootloader, 'rb') as bf:
    bootloader = bytes(bf.read())

    if len(bootloader) == 512:    #single block boot loader
        with open(args.diskimage, 'r+b') as df:
            if format == '.po' or format == '.PO':
                df.seek(0)
                df.write(bytes(bootloader))
            
            elif format == '.dsk' or format == '.DSK':
                df.seek(0) 
                df.write(bytes(bootloader[0:256]))                
                df.seek(14*256)
                df.write(bytes(bootloader[256:512]))            

    elif len(bootloader) > 1024:  #two block boot loader (binary needs to be truncated)
        with open(args.diskimage, 'r+b') as df:
            df.seek(0)
            df.write(bytes(bootloader[0:1024]))
    else:
        print("incorrect boot loader size")
        exit(1)
