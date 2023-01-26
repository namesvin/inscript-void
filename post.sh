#!/bin/bash
dmesg | grep -q "EFI v"    # -q tell grep to output nothing
if [ $? -eq 0 ]      # check exit code; if 0 EFI, else BIOS
then
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub grub-x86_64-efi && grub-install --target=x86_64-efi --efi-directory=/boot && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
else
    echo "xbps-install -Suy xbps && xbps-install -uy && xbps-install -y base-system && xbps-remove -y base-voidstrap && xbps-install -y grub && grub-install ${DISK}1 && grub-mkconfig -o /boot/grub/grub.cfg && xbps-reconfigure -fa && passwd root" > /mnt/void/root/post.sh
fi
