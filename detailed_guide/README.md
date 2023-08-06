# Overview
This folder contains al the steps carried out to set everything up.
This file shows the whole process. Individual sections can be found independently in the rest of the files under this directory. 

# Table of contents

- [Overview](#Overview)
- [Arch installation](#arch-installation)
- [Installing DWM](#installing-dwm)
- [Configuring DWM](#configuring-dwm)


# Arch installation
This section will cover the instalation of Arch Linux and will end after successfully booting into a fresh Arch install.

Most of the steps are taken from the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide) and [Antonio's dotfiles](https://github.com/antoniosarosi/dotfiles).

## Automatic installation
It should be noted that te installation can be done by running the "archinstall" script. Recommended, just run:
```bash
archinstall
```
**[From now on it is assumed that a manual installation is about to be performed. It is also assumed that the iso has been downloaded and the installation medium prepared.]**

## Pre-installation
This section contains some convenient commands to run after booting the live environment.
### Basic interaction
Basic interaction meaning changing the keyboard layout and font.

This is an example on how to change the keyboard layout to spanish.
```bash
loadkeys es
```
The font can be made bigger by running the `setfont` command.
```bash
setfont ter-124b
```

### Keyring
To determine if packages are authentic, pacman uses GnuPG keys in a web of trust model. Each user also has a unique PGP key, which is generated when pacman-key is configured.

[Learn more](https://wiki.archlinux.org/title/Pacman/Package_signing)
#### Initializing the keyring
To initialize the *pacman* keyring run:
```bash
sudo pacman-key --init
```
Then, the initial setup of keys is achieved using:
```bash
sudo pacman-key --populate
# or
sudo pacman-key --populate archlinux
```
This should avoid *invalid signature or related* errors when downloading packages.

#### Management
The keyring can be manually refreshed running:
```bash
sudo archlinux-keyring-wkd-sync
```
On fresh installs the [systemd](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/tree/master/wkd_sync) timer `archlinux-keyring-wkd-sync.timer` runs by default, periodically updating the keyring. On old installs is can be activated by running:
```bash
sudo systemctl enable archlinux-keyring-wkd-sync.timer
```

### Synchronize system packages
Simply run:
```bash
sudo pacman -Sy
```

### Update the system clock
In the live environment [systemd-timesyncd](https://wiki.archlinux.org/title/Systemd-timesyncd) is enabled by default.

I ran into an issue where `systemd-timesyncd.service` did not receive responses to the requests made to the default NTP servers (such as *0.arch.pool.ntp.org*).

Use [timedatectl(1)](https://man.archlinux.org/man/timedatectl.1) to ensure the system clock is accurate.
```bash
timedatectl
```
If something is wrong, check the status of the server and view whether it is timing out.
```bash
systemctl status systemd-timesyncd.service
```
A possible workaround is [installing](https://wiki.archlinux.org/title/Chrony) [Chrony](https://chrony-project.org/). And activate the service.
```bash
sudo pacman -S chrony
systemctl start chronyd.service
```
Weirdly enough timesyncd did not work in another desktop despite ntpdate having success when quering the same servers and making sure no other service was holding port 123.

### Partitioning
#### Identifyng the disk
Locate the drive where the installation should be made with
```bash
fdisk -l
# or
lsblk
```

#### Partition creation
Create partitions with the `fdisk` utility. Example layout: boot_partition (boot > 300 MiB && boot < 1 GiB), swap ( swap > 512 MiB), root_partition (remainder of the space). Just press `n` a couple times.
```bash
fdisk /dev/the_disk_to_be_partitioned
```

#### Partition formatting
Root partition:
```bash
mkfs.ext4 /dev/root_partition
```
Swap partition:
```bash
mkswap /dev/swap_partition
```
EFI system partition:
```bash
mkfs.fat -F 32 /dev/efi_system_partition
```

### Mounting the filesystems
First, mount the root volume to `/mnt`. 
```bash
mount /dev/root_partition /mnt
```
For UEFI systems, mount the EFI system partition:
```bash
mount --mkdir /dev/efi_system_partition /mnt/boot
```
Is a [swap](https://wiki.archlinux.org/title/Swap) volume was created, enable it with [swapon(8)](https://man.archlinux.org/man/swapon.8).
```bash
swapon /dev/swap_partition
```

## Installation
The [pacstrap(8)](https://man.archlinux.org/man/pacstrap.8) script will install the [base](https://archlinux.org/packages/?name=base) package, Linux [kernel](https://wiki.archlinux.org/title/Kernel) and firmware for common hardware. Run the following to install it on the mounted partition.
```bash
pacstrap -K /mnt  base linux linux-firmware
```


## System configuration
Now, it is time to configure the system!

### Fstab file generation
First, an [fstab](https://wiki.archlinux.org/title/Fstab) file should be created, this file defines how disk partitions, various other block devices, or remote file systems should be mounted into the system.
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Chroot
Change root into the new system.
```bash
arch-chroot /mnt
```

### Basic configuration
#### Install an editor
Install an editor of your choice:
```bash
sudo pacman -S vim neovim
```

#### Enable parallel downloads
Modify /etc/pacman.conf and uncomment the line:
```bash
#ParallelDownloads = 5
```
#### Set the time zone
This will create an `/etc/localtime` symlink that points to a zoneinfo file under `/usr/share/zoneinfo/`.
```bash
ln -sf /usr/share/zoneinfo/Region/City
```
Then, set the Hardware Clock from the System Clock, and update the timestamps and generate `/etc/adjtime`.
```bash
hwclock --systohc
```
This command assumes the hardware clock is set to UTC.

#### Localization
Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and other needed locales. Generate the locales by running:
```bash
locale-gen
```

Create the [locale.conf(5)](https://man.archlinux.org/man/locale.conf.5) file, and set the LANG variable accordingly:
```bash
LANG=en_US.UTF-8
```

#### Keyboard layout
To make the keyboard layout persistent, modify [vconsole.conf(5)](https://man.archlinux.org/man/vconsole.conf.5).
Edit or create the file `/etc/vconsole.conf`. In this case:
```bash
KEYMAP=es
```

### Network manager
In order to have networking configured on the first boot automatically, I opted on using the NetworkManager service. Install it with:
```bash
sudo pacman -S networkmanager
```
Then enable it so it runs on startup.
```bash
systemctl enable NetworkManager
```

### Bootloader installation
In this case, [GRUB](https://wiki.archlinux.org/title/GRUB) will be installed. Thus GRUB itself will be installed alongside [efibootmgr](https://wiki.archlinux.org/title/EFISTUB) and [os-prober](https://linux.afnom.net/post-install/os-prober.html). `os-prober` is used to detect other operating systems on the device. It will be used alongside `grub-mkconfig` to detect any operating systems that haven't been automatically picked up.
```bash
sudo pacman -S grub efibootmgr os-prober
```
Run the following commands:
```bash
grub-install --target=x86_64-efi --efi-directory=/boot

os-prober

grub-mkconfig -o /boot/grub/grub.cfg
```

### User creation
Giving root user a password:
```bash
passwd
```
Adding a new user (-m creates home directory)
```bash
useradd -m username
passwd username
usermod -aG wheel,video,audio,storage username
```
In order to have root privileges sudo is requiered.
```bash
sudo pacman -S sudo
```
Edit /etc/sudoers and uncomment the following line:
```bash
## Uncomment to allow members of group wheel to execute any command
# %wheel ALL=(ALL) ALL
```

### Reboot
Everything should be set up so this sections ends with a reboot of the system.
```bash
# Exit out of ISO image, unmount it and remove it
exit
umount -R /mnt
reboot
```

Once booted and logged in I recommend looking around and doing minor changes such as creating `ll` alias in the `~/.bashrc` file. Just add the following line:
```bash
alias ll='ls -alF'
```
Then run:
```bash
source ~/.bashrc
```

# Installing dwm
This section picks up after booting into the system.

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

# Configuring DWM
This section contains the configuring process of DWM as well as other utilities and software.

## Installing nvchad
There are many choices in life. [chad](https://nvchad.com/):
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
```

### Installing dependencies
It requires nerd-fonts and ripgrep
```bash
sudo pacman -S ttf-nerd-fonts-symbols
sudo pacman -S ripgrep
```

Now, if this was done in `st`, simply restart the terminal and open `nvim`.

## Autostarting stuff with Lightdm
Looking at `/etc/lightdm/Xsession` it is where it looks at:
```bash
for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/xprofile"; do
    if [ -f "$file" ]; then
        echo "Loading profile from $file";
        . "$file"
    fi
done
```
So, just create `~/.xprofile` and populate it with custom configuration. For example, to set the background:
```bash
~/.fehbg &
```
Where `~/.fehbg`:
```bash
#!/bin/sh
feh --no-fehbg --bg-fill 'path/to/image'
```

## Configuring DWM
The configuration is done in the `~/.config/dwm/config.h ` file. There is not much to say about it, just read the code.
### Patching
Patching is done the following way:
1. After downloading the patch, run:
```bash
patch -p1 < /path/to/patch
```
2. If the automatic patching was successfull, recompile the changes:
```bash
make # To detect errors
sudo make install # To make the installation
```
3. To view the changes, log out and back in to restart the Xsession.

#### Considerations
Sometimes, the automatic patching might fail. In this cases, open the `.rej` file created and manually add the lines where they were supposed to be.

Patches will affect the `config.def.h` file. This additions must be moved into `config.h`. Diff both files to see what is new in `config.def.h` and yank or modify it in `config.h`.

For patches like [alpha](https://dwm.suckless.org/patches/alpha/) to work, a compositor is needed.
```bash
sudo pacman -S picom
```
Run it in your autostart file. In this case, add the following line to `~/.xprofile`:
```bash
picom &
```

#### Patches
- [bottomstack](https://dwm.suckless.org/patches/bottomstack/)
- [fullgaps](https://dwm.suckless.org/patches/fullgaps/)
- [viewontag](https://dwm.suckless.org/patches/viewontag/)
- [dwm-alpha-systray](https://github.com/bakkeby/patches/blob/master/dwm/dwm-alpha-systray-6.3_full.diff). Installing alpha and then systray and viceversa did not work (apparently these two patches do conflict). Thankfully this exists.

* [alpha](https://dwm.suckless.org/patches/alpha/)
*  [systray](https://dwm.suckless.org/patches/systray/)

### Status bar
There are multiple ways to configure what is shown in the status bar: by using a suckless tool calle [slstatus](https://tools.suckless.org/slstatus/), by running a script that changes the name of the X root window, o by using a patch called [setstatus](https://dwm.suckless.org/patches/setstatus/).

These methods involve adding something to `~/.xprofile`. If your final build will have multiple window managers, it is recommended to install the [autostart](https://dwm.suckless.org/patches/autostart/) patch and run dwm-specific things from there.

#### slstatus
slstatus is easy to configure and use. Install it by:
```bash
git clone git://git.suckless.org/slstatus ~/.config/slstatus
cd ~/.config/slstatus && sudo make install
```
To run it, add the following line to the `~/.xprofile` file.
```bash
slstatus &
```
The configuration of what is shown is done in the `~/.config/slstatus/config.h` file.
For example, to display CPU, RAM and date, the argument struct can be populated this way:
```c
static const struct arg args[] = {
    /*function format               argument */
    { cpu_perc, " \uf4bc %s%% | ",    NULL },
    { ram_perc, "\ue266 %s%% - ",     NULL },
    { ram_used, "%s | ",              NULL },
    { datetime, "%s ", "%d/%m/%Y | %H:%M:%S" },
}
```
Additionally, if you want to do something else, like showing the number of pending updates, you can add a custom command:
```c
static const struct arg args[] = {
    /*function format               argument */
    { run_command, " %s updates |",    "{ timeout 20 checkupdates 2>/dev/null || true; } | wc -l" },
    { cpu_perc, " \uf4bc %s%% | ",    NULL },
    { ram_perc, "\ue266 %s%% - ",     NULL },
    { ram_used, "%s | ",              NULL },
    { datetime, "%s ", "%d/%m/%Y | %H:%M:%S" },
}
```
Though in this case you might not want to check for updates every second. For that I took inspiration from this [post](https://www.reddit.com/r/suckless/comments/kdsl1c/independently_updating_commands_in_slstatus/). And created the cron job.

#### xsetroot way
The [status bar](https://dwm.suckless.org/status_monitor/) is stored in the WM_NAME X11 property of the root window, which is managed by dwm. 
To change this name, simply run:
```bash
xsetroot -name "string"
```
In order to make this status bar show information periodically, the general practice is to create a script that autostarts and performs the refresh in a while loop. 
For example, inspired from [siduck](https://github.com/siduck/chadwm/blob/main/scripts/bar.sh):
```bash
#!/bin/sh

interval=0

pkg_updates() {
    updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l)
    printf "$updates"" updates"
}

cpu() {
    cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
    printf "CPU "
    printf "$cpu_val"
}

mem() {
    used_mem=$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)
    printf "MEM "
    printf "$date_val"
}

date_clock() {
    date_val=$(date "+%d/%m/%Y | %H:%M:%S")
    printf "$date_val"
}

while true; do
    # Check for package updates every hour
    [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
    interval=$((interval + 1))

    sleep 1 && xsetroot -name "| $updates | $(cpu) | $(mem) | $(date_clock)"
```

Now simply add the following line to the `.xprofile` file mentioned above.
```bash
/path/to/script &

# for example:
~/.config/dwm/script_name.extension &
```

#### setstatus way
There is a patch called [setstatus](https://dwm.suckless.org/patches/setstatus/) that replaces `xsetroot`. The status will be modified with:
```bash
dwm -s "new_status"
```

## st
The same philosophy applies to the simple terminal. Simply patch it. I just added scroll and alpha. Not much to comment.

## dmenu
Patches:
- [alpha](https://tools.suckless.org/dmenu/patches/alpha/)
- [center](https://tools.suckless.org/dmenu/patches/center/)
- [numbers](https://tools.suckless.org/dmenu/patches/numbers/)
- [dracula](https://tools.suckless.org/dmenu/patches/dracula/)
- [grid](https://tools.suckless.org/dmenu/patches/grid/)
- [gridnav](https://tools.suckless.org/dmenu/patches/gridnav/)