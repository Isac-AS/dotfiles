# Installation
This page adds some explanations to the [guide](https://github.com/korvahannu/arch-nvidia-drivers-installation-guide) created by [Hannu Korvala](https://github.com/korvahannu).

## Installing the driver packages
1. The installation might depend on your card. Find your [nvidia card from this list](https://nouveau.freedesktop.org/CodeNames.html).
2. Check what driver packages you need to install from the list below

| Driver name  | Base driver | OpenGL | OpenGL (multilib) |
| ------------- | ------------- | ------------- |  ------------ | 
| Maxwell (NV110) series and newer  | nvidia | nvidia-utils | lib32-nvidia-utils |
| Kepler (NVE0) series  | nvidia-470xx-dkms  | nvidia-470xx-utils | lib32-nvidia-470xx-utils |
| GeForce 400/500/600 series cards [NVCx and NVDx] | nvidia-390xx  | nvidia-390xx-utils  | lib32-nvidia-390xx-utils |

3. Install the correct packages. Something like:
```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
```
Note that nvidia-settings is not necessary but recommended. It is a graphical tool that can be used to tweak certain settings or move around the monitors in a multihead setup (graphically).

## Enabling DRM kernel mode setting
[Enabling](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) DRM ([Direct Rendering Manager](https://en.wikipedia.org/wiki/Direct_Rendering_Manager)) Kernel Mode setting enables the Direct Rendering Manager. This is a subsystem that exposes an API that user-space programs can use to send commands and data to the GPU and perform operations such as configuring the mode setting of the display.

1. Add the kernel parameter
- Go to your grub file with ```sudo vim /etc/default/grub```
- Find ```GRUB_CMDLINE_LINUX_DEFAULT```
- Append the line with ```nvidia-drm.modeset=1```
- For example: ```GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"```
- Save the file with *CTRL+O*
- Finish the grub config with ```sudo grub-mkconfig -o /boot/grub/grub.cfg```

2. Add the early loading
- Go to your mkinitcpio configuration file with ```sudo nano /etc/mkinitcpio.conf```
- Find ```MODULES=()```
- Edit the line to match ```MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)```
- Save the file with *CTRL+O*
- Finish the mkinitcpio configuration with ```sudo mkinitcpio -P```

[mkinitcpio](https://wiki.archlinux.org/title/Mkinitcpio) is a Bash script used to create an [initial ramdisk](https://en.wikipedia.org/wiki/Initial_ramdisk) environment. The script can fail if the boot partition is not big enough. A "not enough space error" can appear. It did happen to me and the solution consisted in resizing the partition with gparted.

Adding this modules to the [mkinitcpio(8)](https://man.archlinux.org/man/mkinitcpio.8) configuration file will load them before anything else is done. As seen in the [Arch Wiki](https://wiki.archlinux.org/title/NVIDIA#mkinitcpio), if this module ([nvidia](https://archlinux.org/packages/?name=nvidia)) is added to the `initramfs`, mkinicpio must be run every time there is a `nvidia` driver update. To automate this process a pacman hook can be added:

3. Adding the pacman hook
- Find the *nvidia.hook* in [Hannu Korvala's repository](https://github.com/korvahannu/arch-nvidia-drivers-installation-guide/blob/main/nvidia.hook) or the [Arch Wiki](https://wiki.archlinux.org/title/NVIDIA#pacman_hook), make a local copy and open the file with your preferred editor.
- Find ```Target=nvidia```
- Replace the *nvidia* with the base driver you installed, e.g. ```nvidia-470xx-dkms```
- Save the file and move it to ```/etc/pacman.d/hooks/``` , for example with ```sudo mv ./nvidia.hook /etc/pacman.d/hooks/```

