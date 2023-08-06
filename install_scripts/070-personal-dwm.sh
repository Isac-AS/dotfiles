#!/bin/sh

git clone https://github.com/Isac-AS/dwm ~/.config/dwm
git clone https://github.com/Isac-AS/st ~/.config/st
git clone https://github.com/Isac-AS/dmenu ~/.config/dmenu
git clone https://github.com/Isac-AS/slstatus ~/.config/slstatus

cd ~/.config/dwm && sudo make install
cd ~/.config/st && sudo make install
cd ~/.config/dmenu && sudo make install
cd ~/.config/slstatus && sudo make install