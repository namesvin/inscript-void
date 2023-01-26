#!/bin/bash

echo "Give disk you want to install on! (/dev/sdX)"
read -r DISK
echo "What should your hostname be?"
read -r HOSTNAME
echo "What should your password be?"
read -r PASSWORD

dd if=/dev/zero of="$DISK" bs=1M count=4

format_bios() {
    size=$(parted -s "$DISK" unit MB print | head -n 2 | tail -n 1 | awk '{ print $3 }')

    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary 0 1M
    parted -s "$DISK" set 1 bios_grub on
    parted -s "$DISK" mkpart primary xfs 1M "$size"
}

format_uefi() {
    size=$(parted -s "$DISK" unit MB print | head -n 2 | tail -n 1 | awk '{ print $3 }')

    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary fat32 0 500
    parted -s "$DISK" set 1 esp on
    parted -s "$DISK" mkpart primary xfs 500 "$size"
}

dmesg | grep -q "EFI v"
if [ $? -eq 0 ]; then
    format_uefi
    mkfs.fat -F 32 "${DISK}"1
    mkfs.xfs -f "${DISK}"2
    mkdir -p /mnt/void/
    mount "${DISK}2" /mnt/void
    mkdir -p /mnt/void/boot
    mount "${DISK}1" /mnt/void/boot
else
    format_bios
    mkfs.xfs -f "${DISK}2"
    mkdir -p /mnt/void/
    mount "${DISK}2" /mnt/void
fi

cd /mnt/void || exit

URL="https://repo-default.voidlinux.org/live/current/"
FILENAME=$(curl -s ${URL} | grep -m 1 "void-x86_64-ROOTFS-" | sed -r 's#^.*<a href="([^"]+)">([^<]+)</a>.*$#\1\t\2#' | sed -n -e 's/\(^.*\)\(\(void\).*\)/\1/p')

curl -fLO ${URL}${FILENAME} && tar xvf void* && rm void*

mount --rbind /sys /mnt/void/sys && mount --make-rslave /mnt/void/sys
mount --rbind /dev /mnt/void/dev && mount --make-rslave /mnt/void/dev
mount --rbind /proc /mnt/void/proc && mount --make-rslave /mnt/void/proc

curl https://raw.githubusercontent.com/glacion/genfstab/master/genfstab >> ~/genfstab
bash ~/genfstab -U -t /mnt/void  >> /mnt/void/etc/fstab

cp /etc/resolv.conf /mnt/void/etc/

echo "tmpfs           /tmp        tmpfs   defaults,nosuid,nodev   0 0" >> /mnt/void/etc/fstab

echo "${HOSTNAME}" > /mnt/void/etc/hostname

dmesg | grep -q "EFI v"    # -q tell grep to output nothing
if [ $? -eq 0 ]      # check exit code; if 0 EFI, else BIOS
then
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub grub-x86_64-efi && xbps-install -y NetworkManager && grub-install --target=x86_64-efi --efi-directory=/boot && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
else
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub && xbps-install -y NetworkManager && grub-install ${DISK}1 && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
fi

chmod u+x /mnt/void/root/post.sh
chroot /mnt/void bash -c /root/post.sh
chroot /mnt/void bash -c "ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/"
chroot /mnt/void bash -c "rm /root/post.sh"
