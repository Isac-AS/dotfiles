# Overview
This directory contains some install scripts to facilitate the process shown in detailed guide.

# Details to remember
This section includes some details involving the modification of certain configuration files just so I personally do not forget when doing a new install.

## Fstab
Verify everything is fine (`/etc/fstab`).

## Pacman
Uncomment ParallelDownloads (`/etc/pacman.conf`).
```bash
ParallelDownloads = 5
```

## Picom
Uncomment line 75 of `/etc/xdg/picom.conf` to:
```bash
fading=false;
#fading=true;
```
I simply prefer things to pop up.

## GTK dark theme
Add the following line to ```/usr/share/gtk-3.0/settings.ini```
```bash
gtk-application-prefer-dark-theme = true
```

## Opening things
This makes a reference to applications trying to open stuff through xdg-open. For example, clicking a link in alacritty.
```bash
pacman -S xdg-utils
```
