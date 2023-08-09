# Installation
This section pretty much adds some explanation to the guide found [here](https://github.com/korvahannu/arch-nvidia-drivers-installation-guide).

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
Note that nvidia-settings is not necessary but recommended.

## Enabling DRM kernel mode setting
[Enabling](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) DRM([Direct Rendering Manager](https://en.wikipedia.org/wiki/Direct_Rendering_Manager)) Kernel Mode setting enables the Direct Rendering Manager. This is a subsystem that exposes an API that user-space programs can use to send commands and data to the GPU and perform operations such as configuring the mode setting of the display.

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
- You might not be able to ```mkinitcpio -P``` if the boot partition is not big enough. I did resize it with gparted and solved the "not enough space error".
3. Adding the pacman hook
- Find the *nvidia.hook* in this repository, make a local copy and open the file with your preferred editor
- Find ```Target=nvidia```
- Replace the *nvidia* with the base driver you installed, e.g. ```nvidia-470xx-dkms```
- Save the file and move it to ```/etc/pacman.d/hooks/``` , for example with ```sudo mv ./nvidia.hook /etc/pacman.d/hooks/```
