# Introduction
This page describes a problem I found on my dual-boot system setup. It was briefly commented on the Arch Installation page. Both the explanation and the solution will be completely expanded in this page. The whole situation is a bit clowny but I hope this ends up being useful to someone in the same situation.

# Problem description
With both operating systems (Windows and Arch) installed and correctly booting, I wanted to add the Windows boot entry to the GRUB installation done in Arch. 
## Context
System with two hard drives. Objective: install Windows in one drive and Arch on the other. 
## Windows installation problem 
### Windows installation problem description
Windows was installed in `Legacy` mode, booting in `BIOS/MBR` mode. This can be checked by:
- Booting into Windows
- Pressing `WIN + R`
- Running `msinfo32.exe`
- Checking the value of `BIOS mode` item (can be either `UEFI` or `Legacy`
This made impossible for `os-prober` to detect windows. `os-prober` looks for an [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition), however, the windows drive consisted of only one partition with everything.

### Not a solution, but nice to have
Go to `/etc/default/grub` and uncomment:
```
# Probing for other operating systems is disabled for security reasons. Read
# documentation on GRUB_DISABLE_OS_PROBER, if still want to enable this
# functionality install os-prober and uncomment to detect and include other
# operating systems.
GRUB_DISABLE_OS_PROBER="false"
```
This will make `grub-mkconfig -o /boot/grub/grub.cfg` to run `os-prober`.

Along with that file modification it is also recommended to install `ntfs-3g` to be able to mount `NTFS` partitions without needing to explicitly specify the mount type.
```bash
pacman -S ntfs-3g
```

### Windows installation problem solution
Format that drive and install Windows again ensuring that:
- The [CSM (Compatibility Support Module)](https://en.wikipedia.org/wiki/UEFI#CSM_booting) is disabled
- The installation medium was properly flashed. Using [Rufus](https://rufus.ie/en/), select `Partition scheme: GPT` and `Target system: UEFI(non CSM)`.

## UEFI Arch entry missing problem
### Why did the UEFI Arch entry dissapear?
To ensure that the Windows installation would not touch the Arch drive, I proceeded to disable that drive through the Motherboard UEFI GUI. Windows was now installed in UEFI mode.

However, the previous boot entry pointing to the Linux boot partition (when mounted: `/boot/EFI/arch/grubx64.efi`) was now missing and I was unable to boot into Arch anymore. I coult boot into the "drive" but that would do nothing as it points to the root partition, not the [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition).

### Adding the entry back
The steps to add the entry back were the following:
- Accessing the EFI shell. The EFI shell was accessed by selecting "Run UEFI shell from USB drive" under the exit section of the UEFI GUI and having the Arch flashed USB connected.
- Once in the EFI shell, **identify the Boot Manager Device**. This can be done using the `map` command. 

It is a bit tricky because part of the output gets cut and I could not found a way to reduce the font size or do any kind of scrolling. I could manage typing `fsX:\` where X is a number (e.g. 0,1,2,3,4) and then tabbing, looking for an autocompletion like `fs3:\EFI\`. Then, keep autocompleting until you can see the path `fs3:\EFI\arch\grubx64.efi`. In fact, if `return` is pressed with that path selected, you will boot into Arch!

- After doing what is described above and having located the entry, it can be added using the [bcfg](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#bcfg) command to modify the UEFI NVRAM entries:
```UEFI
bcfg boot add 0 fs2:\EFI\arch\grubx64.efi "Arch"
```
- Then check the list of current boot entries:
```
bcfg boot dump -v
```
This should be it. After rebooting the system the boot option should show up in the GUI.

# Solution to the initial problem
Finally, after booting back into Arch, with `GRUB_DISABLE_OS_PROBER="false"` running:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
did successfully detect and add the Windows entry to GRUB.

