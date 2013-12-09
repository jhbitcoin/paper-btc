===========================
Bitcoin Live CD Instructions
===========================

Create a Live CD image with paper wallet tools in it.
These instructions assume you are running a 32-bit Debian Wheezy.


Install Necessary Packages
==========================

    $ sudo apt-get install debootstrap genisoimage squashfs-tools syslinux


Create Work Environment
=======================


Create Work Folder
------------------

First of you need to create a folder for the project.

    $ mkdir LiveCD
    $ cd LiveCD
    $ mkdir iso


Create chroot
-------------

    $ sudo debootstrap --arch i386 wheezy ./wheezy-chroot http://http.debian.net/debian/


Enter chroot
------------

    $ sudo mount --bind /dev/ wheezy-chroot/dev
    $ sudo chroot wheezy-chroot
    # mount -t proc none /proc
    # mount -t sysfs none /sys
    # mount -t devpts none /dev/pts

    # export HOME=/root
    # export LC_ALL=C
    # export LANG=C


Tweak chroot
------------

Add additional sources for future dependencies

    # echo "deb http://http.debian.net/debian wheezy main contrib non-free" > /etc/apt/sources.list

Set hostname and update hosts file
    # echo "bitcoin-tools" > /etc/hostname
    # echo "127.0.1.1	bitcoin-tools" >> /etc/hosts

Install packages for programs needed on the live cd
    # apt-get update
    # apt-get install -y live-boot live-config-sysvinit live-config live-boot-initramfs-tools git qrencode dialog bc
Answer the questions it asks.

Set CHARMAP to UTF-8 to make the QR codes work.

    # sed -i 's/ISO-8859-15/UTF-8/' /etc/default/console-setup

Disable the network setup scripts from running at boot.

    # echo "CONFIGURE_INTERFACES=no" >> /etc/default/networking

Disable TTY 2-6 by editing /etc/inittab. Comment out the lines

    2:23:respawn:/sbin/getty 38400 tty2
    3:23:respawn:/sbin/getty 38400 tty3
    4:23:respawn:/sbin/getty 38400 tty4
    5:23:respawn:/sbin/getty 38400 tty5
    6:23:respawn:/sbin/getty 38400 tty6

Start paper-wallet on boot.

    # echo "/usr/local/bin/paper-wallet.sh" >> /etc/profile


==========================================
Install bitcoin related libraries/programs
==========================================

    # cd /usr/local/src
    # git clone https://github.com/spesmilo/sx.git
    # cd sx
    # ./install-sx.sh

Answer yes when it asks if you want to install the packages.
Once it finnishes without error messages. Clean up all the source files to decrease the size of the final image.

    # cd ..
    # rm -rf *

Install paper-wallet.sh
-----------------------

    # cd /usr/local/bin
    # wget https://raw.github.com/gehlm/paper-btc/master/paper-wallet.sh
    # chmod +x paper-wallet.sh


==============================================
Install custom kernel with networking disabled
==============================================

Build kernel
------------

    # cd /usr/src
    # apt-get install linux-source kernel-package linux-image-486
    # tar vxf linux-source-3.2.tar.bz2
    # cd linux-source-3.2
    # cp /boot/config-3.2.0-4-486 ./.config

If you are building this on a 64-bit host. Prepend the make/make-kpkg lines with linux32.

    # make oldconfig
    # make menuconfig

Alternativly, use the supplied config file and save it to LiveCD/wheezy-chroot/usr/src/linux-source-3.2/.config

    # wget -O ./.config https://raw.github.com/gehlm/paper-btc/master/config-3.2.51

Disable everything in "Networking support" then head into "Device Drivers".
Disable everything in "Network device support". Including in the "Ethernet
driver support" and "USB Network Adapters" subdirectory. Some things can't
be disabled. But leaving them as {M} won't be a problem. After that head
back into "Networking support" in the top directory and disable "Wireless".
Exit and save the configuration.

    # make-kpkg --initrd --cross-compile - --arch=i386 --revision=01bitcointools kernel_image

This will take quite some time.


Install kernel
--------------

    # dpkg -i /usr/src/linux-image-3.2.51_01bitcointools_i386.deb
    # apt-get --reinstall install live-boot-initramfs-tools


Clean up
--------
    # cd /
    # apt-get --purge autoremove linux-source linux-image-486 linux-source-3.2 kernel-package
    # rm -rf /usr/src/linux-source-3.2


============
Leave chroot
============

    # umount /proc || umount -lf /proc
    # umount /sys
    # umount /dev/pts
    # exit
    $ sudo umount wheezy-chroot/dev

===============
Set up isolinux
===============

    $ wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.02.tar.bz2
    $ tar vxf syslinux-6.02.tar.bz2
    $ mkdir iso/isolinux/
    $ cp syslinux-6.02/bios/core/isolinux.bin ./iso/isolinux
    $ cp syslinux-6.02/bios/com32/elflink/ldlinux/ldlinux.c32 ./iso/isolinux/

Create a isolinux.cfg to make the system automaticly boot into the live environment
    $ echo -e "default 1\n\
	\n\
	label 1\n\
	\tlinux /live/vmlinuz\n\
	\tinitrd /live/initrd.img\n\
	\tappend boot=live config vga=791" > ./iso/isolinux/isolinux.cfg

Create folder that contains the filesystem and kernel
    $ mkdir iso/live
    $ cp wheezy-chroot/boot/vmlinuz-3.2.51 ./iso/live/vmlinuz
    $ cp wheezy-chroot/boot/initrd.img-3.2.51 ./iso/live/initrd.img

Optionally remove the old kernel from the chroot environment to save space.
    $ sudo chroot wheezy-chroot apt-get --purge autoremove linux-image-3.2.51

============
Generate ISO
============

    $ sudo mksquashfs wheezy-chroot/ ./iso/live/filesystem.squashfs
    $ cd iso
    $ find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt
    $ sudo genisoimage -D -r -V "Bitcoin Tools" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../bitcoin-tools.iso .
    $ cd ..

Make the isofile a hybrid iso so that it works both from CDs and USB drives.
    $ isohybrid bitcoin-tools.iso


