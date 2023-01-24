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
sudo xbps-install -Syu git rofi i3 polybar xorg font-awesome5 pywal zsh
cd ~
git clone https://github.com/namesvin/void-dots
cd void-dots
git clone https:///github.com/lukesmithxyz/st
cd st
sudo make clean install
cd ..
mv * ../
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
chsh /bin/zsh
