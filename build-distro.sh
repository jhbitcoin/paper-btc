#!/bin/bash

echo "Install Necessary Packages"
echo "=========================="
sudo apt-get install debootstrap genisoimage squashfs-tools syslinux


echo "Create Work Environment"
echo "======================="
mkdir LiveCD
cd LiveCD
mkdir iso

echo "============="
echo "Create chroot"
echo "============="
sudo debootstrap --arch i386 wheezy ./wheezy-chroot http://http.debian.net/debian/

echo "============"
echo "Enter chroot"
echo "============"
sudo mount --bind /dev/ wheezy-chroot/dev
sudo chroot wheezy-chroot
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

HOME=/root
LC_ALL=C
LANG=C


echo "============"
echo "Tweak chroot"
echo "============"
echo "deb http://http.debian.net/debian wheezy main contrib non-free" > /etc/apt/sources.list


echo "=================================="
echo "Set hostname and update hosts file"
echo "=================================="
echo "bitcoin-tools" > /etc/hostname
echo "127.0.1.1	bitcoin-tools" >> /etc/hosts


echo "==================================================="
echo "Install packages for programs needed on the live cd"
echo "==================================================="
apt-get update
apt-get install -y live-boot live-config-sysvinit live-config live-boot-initramfs-tools git qrencode dialog bc


echo "==============================================="
echo "Set CHARMAP to UTF-8 to make the QR codes work."
echo "==============================================="
sed -i 's/ISO-8859-15/UTF-8/' /etc/default/console-setup


echo "======================================================="
echo "Disable the network setup scripts from running at boot."
echo "======================================================="
echo "CONFIGURE_INTERFACES=no" >> /etc/default/networking


echo "=============================================================="
echo "Disable TTY 2-6 by editing /etc/inittab. Comment out the lines"
echo "=============================================================="
sed -i 's/2:23/#2:23/' /etc/inittab
sed -i 's/3:23/#3:23/' /etc/inittab
sed -i 's/4:23/#4:23/' /etc/inittab
sed -i 's/5:23/#5:23/' /etc/inittab
sed -i 's/6:23/#6:23/' /etc/inittab


echo "==========================="
echo "Start paper-wallet on boot."
echo "==========================="
echo "/usr/local/bin/paper-wallet.sh" >> /etc/profile


echo "=========================================="
echo "Install bitcoin related libraries/programs"
echo "=========================================="
cd /usr/local/src
git clone https://github.com/spesmilo/sx.git
cd sx
./install-sx.sh
cd ..
rm -rf *
cd /usr/local/bin
wget https://raw.github.com/gehlm/paper-btc/master/paper-wallet.sh
chmod +x paper-wallet.sh


echo "=============================================="
echo "Install custom kernel with networking disabled"
echo "This will take some time"
echo "=============================================="
cd /usr/src
apt-get install linux-source kernel-package linux-image-486
tar vxf linux-source-3.2.tar.bz2
cd linux-source-3.2
wget -O ./.config https://raw.github.com/gehlm/paper-btc/master/config-3.2.51
make-kpkg --initrd --cross-compile - --arch=i386 --revision=01bitcointools kernel_image


echo "=============="
echo "Install kernel"
echo "=============="
dpkg -i /usr/src/linux-image-3.2.51_01bitcointools_i386.deb
apt-get --reinstall install live-boot-initramfs-tools


echo "========"
echo "Clean up"
echo "========"
cd /
apt-get --purge autoremove linux-source linux-image-486 linux-source-3.2 kernel-package
rm -rf /usr/src/*
apt-get clean


echo "============"
echo "Leave chroot"
echo "============"
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit
sudo umount wheezy-chroot/dev


echo "==============="
echo "Set up isolinux"
echo "==============="
wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.02.tar.bz2
tar vxf syslinux-6.02.tar.bz2
mkdir ./iso/isolinux
cp syslinux-6.02/bios/core/isolinux.bin ./iso/isolinux/
cp syslinux-6.02/bios/com32/elflink/ldlinux/ldlinux.c32 ./iso/isolinux/


echo "======================================================"
echo "Create a isolinux.cfg to make the system automatically"
echo "boot into the live environment"
echo "======================================================"
echo -e "default 1\n\n\
	label 1\n\
	\tlinux /live/vmlinuz\n\
	\tinitrd /live/initrd.img\n\
	\tappend boot=live config vga=791" > ./iso/isolinux/isolinux.cfg


echo "====================================================="
echo "Create folder that contains the filesystem and kernel"
echo "====================================================="
mkdir ./iso/live
cp wheezy-chroot/boot/vmlinuz-3.2.51 ./iso/live/vmlinuz
cp wheezy-chroot/boot/initrd.img-3.2.51 ./iso/live/initrd.img


echo "================================================================"
echo "Remove the old kernel from the chroot environment to save space."
echo "================================================================"
sudo chroot wheezy-chroot apt-get --purge autoremove linux-image-3.2.51
sudo chroot wheezy-chroot apt-get clean

echo "============"
echo "Generate ISO"
echo "============"
sudo mksquashfs wheezy-chroot/ ./iso/live/filesystem.squashfs
cd iso
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt
sudo genisoimage -D -r -V "Bitcoin Tools" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../bitcoin-tools.iso .
cd ..


echo "==================================================="
echo "Make the isofile a hybrid iso so that it works both"
echo "from CDs and USB drives."
echo "==================================================="
sudo isohybrid bitcoin-tools.iso

