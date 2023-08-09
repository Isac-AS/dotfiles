# Dotfile management
This page explains the usage of [GNU Stow](https://www.gnu.org/software/stow/) applied to manage user configuration files.

The behaviour of Stow is better explained with examples, so lets take my own personal configuration for alacritty.

## Dotfiles under `~/.config/`
As seen in the repo, the actual `alacritty.yml` file is under `dotfiles/alacritty/.config/alacritty/`.

After running:
```bash
stow --target=$HOME alacritty
```
This entry is created under the `~/.config/` directory:
```
lrwxrwxrwx  1 isac isac   45 MONTH  DAY HH:MM  alacritty -> ../repos/dotfiles/alacritty/.config/alacritty/
```

1. A way of visualizing the behaviour is to imagine the process of "adding an entry", in this case, the alacritty entry. This entry is the first `dotfiles/alacritty` dir.
2. Now we have to imagine that this first directory is the `target` directory, in most cases, `$HOME`.
3. Finally, the concrete config file `alacritty.yml` must be placed on a relative path from the target, `$HOME/` + `.config/alacritty/alacritty.yml`.

# Dotfiles directly on the home directory
For files like `.xprofile`, `.bashrc`, `.fehbg` or `.xbindkeysrc`, that are directly on the home directory are easier to stow. Simply put them under a directory, the name does not matter. 
In this case, as there are a lot of files that start with 'x', I decided to name it `dotfiles/X`.
These files can be directly "stowed" running:
```bash
stow --target=$HOME X
```

This way, modifications to the files themselves will be reflected on their real location, making it very easy to keep track of them.
