#!/bin/sh

cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git

sudo chown -R user:user ./yay-git
cd yay-git
makepkg -si