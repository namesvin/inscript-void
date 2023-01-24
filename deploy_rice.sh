#!/bin/bash
cd ~
sudo xbps-install -Syu git
git clone https://github.com/namesvin/void-dots
cd void-dots
git clone https:///github.com/lukesmithxyz/st
cd st
sudo make clean install
cd ..
mv * ../
# install everything thx uwu
