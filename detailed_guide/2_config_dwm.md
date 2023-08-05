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
### Patching
Patching is done the following way:
1. Go to the patch. For example, [bottomstack](https://dwm.suckless.org/patches/bottomstack/)
2. Run
```bash
patch -p1 < /path/to/patch
```
3. This will generate some files such as config.def.h. You can ignore it, take a look, remove it... Then run
```bash
make
sudo make install
```
In fact, this has to be done every time something is changed.
4. Then to view the changes, log out and back in to restart the Xsession.

#### Patches
- bottomstack
- setstatus
- systray

### Status bar
#### xsetroot way
The [status bar](https://dwm.suckless.org/status_monitor/) is stored in the WM_NAME X11 property of the root window, which is managed by dwm. 
To change this name, simply run:
```bash
xsetroot -name "string"
```
In order to make this status bar show information periodically, the general practice is to create a script that autostarts and performs the refresh in a while loop. 
For example, inspired from [siduck](https://github.com/siduck/chadwm/blob/main/scripts/bar.sh):
```bash
#!/bin/bash

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
