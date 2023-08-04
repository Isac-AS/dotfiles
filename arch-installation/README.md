# Arch installation process
This document simply compiles the steps followed to install Arch manually. 

Most of the steps are taken from the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide) and [Antonio's dotfiles](https://github.com/antoniosarosi/dotfiles).


## Basic interaction
Changing the keyboard layout to spanish
```loadkeys es
```
Changing the font (just making it a big bigger)
```setfont ter-124b
```

## Archinstall
The installation can be done with the archinstall script just by running:
```archinstall
```
The rest of the document contains a manual installation.

## Synchronize system packages
```# pacman -Sy
```

## Keyring
### Initializing the keyring
```pacman-key --init

```
### Populating the keyring
```# pacman-key --populate
or
# pacman-key --populate archlinux
```

### Archlinux keyring
Manually refresh the keyring:
```sudo archlinux-keyring-wkd-sync
```

### NTP
The service systemd-timesyncd.service can get stuck not correctly receiving responses and constantly timing out.
Check the status with:
```systemctl status systemd-timesyncd.service
```

The workaround was to [install](https://wiki.archlinux.org/title/Chrony) [Chrony](https://chrony-project.org/). And activate the service.
```# pacman -S chrony
# systemctl start chronyd.service
``` 
Weirdly enough timesyncd did not work in another desktop despite ntpdate having success when quering the same servers and making sure no other service was holding port 123.
Hopefully it is has already been fixed.

## Partitions
Locate the drive with 
```# fdisk -l
```
Create partitions with 
```# fdisk
```

Boot (~300MiB), swap (~600MiB), root (rest of space)

Format root partition with

```mkfs.ext4 /dev/root_partition
```

Format swap partition

```mkswap /dev/swap_partition
```

Format efi system partition
```mkfs.fat -F 32 /dev/efi_system_partition

```

Finally mount the filesystems

```mount /dev/root_partition /mnt
```

```mount --mkdir /dev/efi_system_partition /mnt/boot
```

```swapon /dev/swap_partition
```

## Installation
Installation of the essential packages
```pacstrap -K /mnt  base linux linux-firmware
```

## System configuration
### Fstab file generation
Generate the fstab file with the command:
```genfstab -U /mnt >> /mnt/etc/fstab
```
### Changing root into the new system
This can be done with:
```arch-chroot /mnt
```

### Basic configuration
Install an editor:
```pacman -S vim neovim
```

Modify /etc/pacman.conf and uncomment the line:
```#ParallelDownloads = 5
```

Time zone
```ln -sf /usr/share/zoneinfo/Region/City
```

Run hwclock to generate /etc/adjtime
```hwclock --systohc
```

Localization
Edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8 and other needed locales. Generate the locales by running:
```locale-gen
```

Create the [locale.conf(5)](https://man.archlinux.org/man/locale.conf.5) file, and set the LANG variable accordingly:

/etc/locale.conf

LANG=en_US.UTF-8

Keyboard layout

Edit or create the file /etc/vconsole.conf. In this case:
```KEYMAP=es
```

### Network manager
Install NetworkManager
```# pacman -S networkmanager
# systemctl enable NetworkManager
```

### Bootloader installation
```# pacman -S grub efibootmgr os-prober
# grub-install --target=x86_64-efi --efi-directory=/boot
# os-prober
# grub-mkconfig -o /boot/grub/grub.cfg
```

### User creation
Giving root user a password:
```# passwd
```

Adding a new user (-m creates home directory)
```useradd -m username
passwd username
usermod -aG wheel,video,audio,storage username
```

Install sudo

```pacman -S sudo
```

Edit /etc/sudoers and uncomment the following line:
```## Uncomment to allow members of group wheel to execute any command
# %wheel ALL=(ALL) ALL
```

Now, proceed to reboot:
```# Exit out of ISO image, unmount it and remove it
exit
umount -R /mnt
reboot
```
