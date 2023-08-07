# Theming LightDM and GRUB
This section focuses on theming what is seen at startup.
## LightDM
The light theme config is done using [aether](https://github.com/NoiSek/Aether#installation). It is simply the best. As seen in the link, the installation requires to have `lightdm-webkit2-greeter` installed.

Previously `lightdm-gtk-greeter` was installed. To change the greeter used, go to `/etc/lightdm/lightdm.conf` and modify `greeter-session` to `lightdm-webkit2-greeter`:
```
greeter-session = lightdm-webkit2-greeter
```
I had already changed this beforehand, but after installing aether, the line was duplicated.

Aether can be found on the AUR so simply:
```bash
yay -S lightdm-webkit-theme-aether
```
That is it! For something to show up in the selected session, change the `guest-session` attribute in `/etc/lightdm/lightdm.conf`. 
```
guest-session=dwm
```
Also check the file for something suspicious after the installation.

## GRUB 
GRUB custimation involves changing the theme directory and pointing to it. Just pick a theme by googling "GRUB themes" and [this](https://www.gnome-look.org/browse?cat=109) will probably pop up. I personally liked this two: [first one](https://github.com/Teraskull/bigsur-grub2-theme), [second one](https://github.com/vinceliuice/grub2-themes).

However! I had problems adding the windows entry. Problem: windows BIOS installed in legacy mode and Arch in EFI. Solution: reinstall windows in EFI.

Make sure to have `os-prober` installed and uncomment the line:
```
GRUB_DISABLE_OS_PROBER="false"
```
in `/etc/default/grub`

Then add the entry by running 
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
