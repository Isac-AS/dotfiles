# Quick links
- [Clean Arch install (Full explanation)](./detailed_guide/). 
- [DWM](https://github.com/Isac-AS/dwm)

# Overview
This document attempts to explain the dotfiles management, [see](#bad-explantation-on-how-to-use-stow).

**This repository contains the steps carried out to set up Arch Linux, installing DWM and configuring this and other suckless software.** Everything is under [detailed_guide](./detailed_guide/). This is not an expert guide, just a guide for myself.

# Bad explantation on how to use stow
The dotfile management is done with [GNU Stow](https://www.gnu.org/software/stow/).

Each of the directories created in the repository (the ones for config files) will act like the home directory. 

Example: alacritty configuration should be stored under `dotfiles/alacritty/.config/alacritty/`. This way, after running
```bash
stow alacritty
```
when being in the `dotfiles` directory, we can visualize "choosing" the alacritty option and stow "placing" the dotfiles on the path given, starting from the home directory (the "alacritty" option, [`dotfiles/alacritty` becomes `dotfiles/~/`] -> `~/.config/alacritty/`).

On the same fashion, regarding files that are directly in the home directory can be placed under a folder. Take the `.xprofile` file. The directory `dotfiles/X` can be created and the `.xprofile` file be put under it (`dotfiles/X/.xprofile`). Running:
```bash
stow X
```
should place `.xprofile` under your home directory.

