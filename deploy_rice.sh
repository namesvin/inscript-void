#!/bin/bash
# Should be ran as normal user!!!!!!!
cd ~
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
./xbps-src pkg spotify
./xbps-src pkg discord
xbps-install --repository hostdir/binpkgs spotify discord
sudo xbps-install -Syu git rofi i3 polybar xorg font-awesome5
cd ~
git clone https://github.com/namesvin/void-dots
cd void-dots
git clone https:///github.com/lukesmithxyz/st
cd st
sudo make clean install
cd ..
mv * ../
