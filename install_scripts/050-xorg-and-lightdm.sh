#!/bin/sh
sudo pacman -S xorg --noconfirm

# Lightdm
sudo pacman -S lightdm --noconfirm
sudo pacman -S lightdm-gtk-greeter --noconfirm
sudo pacman -S lightdm-gtk-greeter-settings --noconfirm
sudo systemctl enable lightdm

# Add entry for DWM
sudo mkdir /usr/share/xsession
sudo cp dmw.desktop /usr/share/xsession/dmw.desktop