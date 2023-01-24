DIR=$(pwd)

echo "Give disk you want to install on! (/dev/sdX)"
read DISK
echo "What should your hostname be?"
read HOSTNAME
echo "What should your password be?"
read PASSWORD

dd if=/dev/zero of=$DISK bs=1M count=4

printf "g\nn\n\n\n+500M\nt\n1\nn\n\n\n\nw\n" | fdisk $DISK

mkfs.fat -F 32 ${DISK}1
mkfs.xfs -f ${DISK}2

mkdir -p /mnt/void/
mount "${DISK}2" /mnt/void
mkdir -p /mnt/void/boot
mount "${DISK}1" /mnt/void/boot

curl -fLO https://raw.githubusercontent.com/glacion/genfstab/master/genfstab
chmod +x genfstab
./genftsab /mnt/void -U >> /mnt/void/etc/fstab

cd /mnt/void

URL="https://repo-default.voidlinux.org/live/current/"
FILENAME=$(curl -s ${URL} | grep -m 1 "void-x86_64-ROOTFS-" | sed -r 's#^.*<a href="([^"]+)">([^<]+)</a>.*$#\1\t\2#' | sed -n -e 's/\(^.*\)\(\(void\).*\)/\1/p')

curl -fLO ${URL}${FILENAME} && tar xvf ${FILENAME} && rm ${FILENAME}

mount --rbind /sys /mnt/void/sys && mount --make-rslave /mnt/void/sys
mount --rbind /dev /mnt/void/dev && mount --make-rslave /mnt/void/dev
mount --rbind /proc /mnt/void/proc && mount --make-rslave /mnt/void/proc

cp /etc/resolv.conf /mnt/void/etc/

echo "tmpfs           /tmp        tmpfs   defaults,nosuid,nodev   0 0" >> /mnt/void/etc/fstab

echo "${HOSTNAME}" > /mnt/void/etc/hostname

dmesg | grep -q "EFI v"    # -q tell grep to output nothing
if [ $? -eq 0 ]      # check exit code; if 0 EFI, else BIOS
then
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub grub-x86_64-efi && grub-install --target=x86_64-efi --efi-directory=/boot && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
  else
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub && grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
fi

chmod u+x /mnt/void/root/post.sh

chroot /mnt/void bash -c /root/post.sh
