# Installing dwm
This section picks up after booting into the system.

Quick reminder update with:
```bash
sudo pacman -Syu
```

## Installing xorg
The first step is to install [Xorg](https://wiki.archlinux.org/title/Xorg), which provides an implementation of the [X Window System](https://en.wikipedia.org/wiki/X_Window_System). This is the most popular display server. X provides the basic framework for a GUI environment: drawing and moving windows on the display device and interacting with a mouse and keyboard. X does not mandate the user interface – this is handled by individual programs. X uses a client–server model: an X server communicates with various client programs. The server accepts requests for graphical output (windows) and sends back user input (from keyboard, mouse, or touchscreen).

Xorg can be installed with the [xorg-server](https://archlinux.org/packages/?name=xorg-server) package.
However, some packages from the [xorg-apps](https://archlinux.org/groups/x86_64/xorg-apps/) group are necessary for certain configuration tasks.
[One installation option for dwm](https://www.chrisatmachine.com/posts/01-dwm) can be running the following:
```bash
sudo pacman -S xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
```
It should be noted that an [xorg](https://archlinux.org/groups/x86_64/xorg/) group is also available, which includes Xorg server packages, packages from the [xorg-apps](https://archlinux.org/groups/x86_64/xorg-apps/) group and fonts. Simply run:
```bash
sudo pacman -S xorg
```

### Config files
Configuration files can be found under the `/etc/X11` directory. Here the directories `/etc/X11/xinit` and `/etc/X11/xorg.conf.d` are found. You can add your own configuration files, ending in `.conf` under the `/etc/X11/xorg.conf.d`. This will be used to configure the monitor setup or change mouse or keyboard behaviour.

### DMPS
[DPMS](https://wiki.archlinux.org/title/Display_Power_Management_Signaling) (Display Power Management Signaling) enables power saving behaviour of monitors when the computer is not in use. I personally do not want monitors to turn off. DPMS and screensaver settings can be modified using the `xset` command. To disable screen saver blanking run.
```bash
xset s off
```
To turn off DPMS:
```bash
xset -dmps
```

## Before installing DWM
### Install git
Totally necessary step and basic tool needed for breathing.
```bash
sudo pacman -S git
```
### Install a browser
Why not?
```bash
sudo pacman -S firefox
```
### Create a config directory
If `neofetch` or `htop` the directory `~/.config` might already exist. This directory is used to save user-specific application configuration. If it does not exist, run:
```bash
mkdir ~/.config
```

## Install DWM
Now it is time to install the [suckless tools](https://suckless.org/): [dwm](https://dwm.suckless.org/), [st](https://st.suckless.org/goals/) and [dmenu](https://tools.suckless.org/dmenu/). DWM being the dynamic window manager, st the simple terminal and dmenu the dynamic menu designed for dwm.

This will just install the software. Configuration comes later.
``` bash
git clone git://git.suckless.org/dwm ~/.config/dwm
git clone git://git.suckless.org/st ~/.config/st
git clone git://git.suckless.org/dmenu ~/.config/dmenu
```
```bash
cd ~/.config/dwm && sudo make install
cd ~/.config/st && sudo make install
cd ~/.config/dmenu && sudo make install
```

## Installing a display manager
A [display manager](https://wiki.archlinux.org/title/Display_manager), or login manager, is typically a graphical user interface that is displayed at the end of the boot process. [LightDM](https://wiki.archlinux.org/title/LightDM) will be installed:
```bash
sudo pacman -S lightdm
```
Additionally `lightdm-gtk-greeter` has to be installed. This is the **default** greeter LightDM attepts to use.
```bash
sudo pacman -S lightdm-gtk-greeter
sudo pacman -S lightdm-gtk-greeter-settings
```
Finally, the service must be enabled:
```bash
sudo systemctl enable lightdm
```

## Adding an entry for DWM in the DM
Create the directory:
```bash
mkdir /usr/share/xsessions
```
And open the file:
```bash
vim /usr/share/xsessions/dwm.desktop
```
The file content should be:
```bash
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic Window Manager
Exec=dwm
Icon=dwm
Type=XSession
```

Now, after rebooting and logging in, you should be into DWM.