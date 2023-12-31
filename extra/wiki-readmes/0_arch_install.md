# Arch installation
This section will cover the instalation of Arch Linux and will end after successfully booting into a fresh Arch install.

Most of the steps are taken from the [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide) and [Antonio's dotfiles](https://github.com/antoniosarosi/dotfiles).

## Automatic installation
It should be noted that the installation can be done by running the "archinstall" script. Recommended, just run:
```bash
archinstall
```
**[From now on it is assumed that a manual installation is about to be performed. It is also assumed that the iso has been downloaded and the installation medium prepared.]**

## Pre-installation
### Before booting the life environment
Make sure the iso file was flashed properly, selecting the UEFI setting. When booting the USB make sure it prompts:
```
Arch Linux install medium (x86_64, UEFI)
```
If instead the following shows up:
```
Arch Linux install medium (x86_64, BIOS)
```
The installation of the boot manager won't be successfull and an error similar to "EFI variables not available in this system" will appear.
To fix this, "re-flash" the USB. Using [Rufus](https://rufus.ie/en/), select `Partition scheme: GPT` and `Target system: UEFI(non CSM)`.

To boot the USB make sure to disable the [CSM](https://en.wikipedia.org/wiki/UEFI#CSM_booting) (Compatibility Support Module). This is a component of the UEFI firmware that provides legacy BIOS compatibility by emulating a BIOS environment.

### Basic interaction
After selecting that option you are prompted in the life environment. In might be interesting to change the keyboard layout and font.


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
Weirdly enough timesyncd did not work in another desktop despite ntpdate having success when quering the same servers and making sure no other service was holding port 123. Chrony works for me.

### Partitioning
#### Identifyng the disk
Locate the drive where the installation should be made with
```bash
fdisk -l
# or
lsblk
```

#### Partition creation
Create partitions with the `fdisk` utility. Press `d` to delete partitions (if there was something on the disk. Press `n` to create a new partition. Use `fdisk` to modify the partition tables.
```bash
fdisk /dev/the_disk_to_be_partitioned
```
Example layout:
| Mount point | Partition                   | Partition type | Suggested size |
| ----------- | --------------------------- | -------------- | -------------- |
| `/mnt/boot` | `/dev/efi_system_partition` | [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition) | At least 300 MiB. If multiple kernels will be installed, then no less than 1 GiB. Give it 500 MiB just in case |
| `[SWAP]` | `/dev/swap_partition` | Linux swap | More than 512 MiB |
| `/mnt` | /dev/root_partition | Linux x86_64 root (/) | Remainder of the device | 

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

If `os-prober` does not detect anything, go to `/etc/default/grub` and uncomment:
```
# Probing for other operating systems is disabled for security reasons. Read
# documentation on GRUB_DISABLE_OS_PROBER, if still want to enable this
# functionality install os-prober and uncomment to detect and include other
# operating systems.
GRUB_DISABLE_OS_PROBER="false"
```
This will make `grub-mkconfig -o /boot/grub/grub.cfg` to run `os-prober`.

If you are looking for a Windows partition entry, and `os-prober` is unable to mount the ntfs partition, install `ntfs-3g`.
```bash
pacman -S ntfs-3g
```
This will allow mounting `ntfs` devices without having to specify `mount -t ntfs [device] [dir]`.

If the problem persists, boot into Windows, press `Win+R`, type `msinfo32.exe` and check the value of **BIOS mode**. If the value is `Legacy` (which happened to me), reinstall Windows making sure an EFI installation will be made. If Windows is booted in Legacy BIOS mode it will not be picked up by os-prober.

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

