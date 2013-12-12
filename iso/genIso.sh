#!/bin/bash

echo "=============="
echo "Setup isolinux"
echo "=============="

rm -rf ./iso/isolinix/
mkdir ./iso/isolinux
cp syslinux-6.02/bios/core/isolinux.bin ./iso/isolinux/
cp syslinux-6.02/bios/com32/elflink/ldlinux/ldlinux.c32 ./iso/isolinux/

echo -e "default 1\n\n\
label 1\n\
\tlinux /live/vmlinuz\n\
\tinitrd /live/initrd.img\n\
\tappend boot=live config vga=791" > ./iso/isolinux/isolinux.cfg

rm -rf ./iso/live/
mkdir ./iso/live
cp wheezy-chroot/boot/vmlinuz-3.2.51 ./iso/live/vmlinuz
cp wheezy-chroot/boot/initrd.img-3.2.51 ./iso/live/initrd.img


echo "============"
echo "Generate ISO"
echo "============"

rm -f ./iso/live/filesystem.squashfs
sudo mksquashfs wheezy-chroot/ ./iso/live/filesystem.squashfs

cd iso
rm -f md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

rm -f ../bitcoin-tools.iso
sudo genisoimage -D -r -V "Bitcoin Tools" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../bitcoin-tools.iso .
cd ..
