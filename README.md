# Inscript
## A void Linux installer script

- Written in 100% BASH
- Easy to use
- This script is a bash script that installs the Void Linux operating system on a specified disk (input by the user) and sets the hostname and password (also input by the user). The script begins by creating a new partition table on the specified disk using fdisk, and then creates a new file system on the partition using mkfs. It then creates a new directory and mounts the partition to that directory. The script then downloads the latest version of Void Linux from a specified URL, extracts the files, and copies them to the mounted partition. It then binds the partition to the system's /sys, /dev and /proc directories, and generates an fstab file. The script also creates a new file in the root directory of the partition that will run commands to install the bootloader, GRUB, configure the system, and set the root password when the system is booted from the partition. The script then makes the post.sh file executable and runs it in the chroot environment.
