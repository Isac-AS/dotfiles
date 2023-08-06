#!/bin/sh

git clone git://git.suckless.org/dwm ~/.config/dwm
git clone git://git.suckless.org/st ~/.config/st
git clone git://git.suckless.org/dmenu ~/.config/dmenu

cd ~/.config/dwm && sudo make install
cd ~/.config/st && sudo make install
cd ~/.config/dmenu && sudo make install