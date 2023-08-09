# Dotfile management
This section is centered on managing dotfiles with [GNU Stow](https://www.gnu.org/software/stow/).

For each of the directories created in the repository will act like the home directory. 

Example: alacritty configuration should be stored under `dotfiles/alacritty/.config/alacritty/`. This way, after running
```bash
stow --target=$HOME alacritty
```
when being in the `dotfiles` directory we can visualize "choosing" the alacritty option and stow "placing" the dotfiles on the path given, starting from the home directory (`~/.config/alacritty/`).

On the same fashion, regarding files that are directly in the home directory can be placed under a folder. Take the `.xprofile` file. The directory `dotfiles/X` can be created and the `.xprofile` file be put under it (`dotfiles/X/.xprofile`). Running:
```bash
stow --target=$HOME X
```
should place `.xprofile` under your home directory.
