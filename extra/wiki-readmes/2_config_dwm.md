# Configuring DWM
This page contains the configuring process of DWM as well as other utilities and software.
It could be called a rice, but it feels really simple to be a rice comparable to those in [r/unixporn](https://www.reddit.com/r/unixporn/?rdt=61146). I personally like it this simple and functional.

## Installing nvchad
There are many choices in life. Be a chad [chad](https://nvchad.com/):
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
```

xclip rocks. Install xclip to have a nice clipboard manager.
```
sudo pacman -S xclip
```

### Installing nvchad dependencies
It requires nerd-fonts and ripgrep
```bash
sudo pacman -S ttf-nerd-fonts-symbols
sudo pacman -S ripgrep
```

### About fonts
Given a clean install has been performed, some characters can appear as a white box. That is because those fonts are missing. Try installing some fonts like:
```
sudo pacman -S noto-fonts ttf-dejavu ttf-liberation noto-fonts-emoji  
```
For chinese, japanese and korean fonts:
```
sudo pacman -S noto-fonts-cjk  
```

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
And the last lines: 
```
# Run user xsession shell script
script="$HOME/.xsession"
if [ -x "$script" -a ! -d "$script" ]; then
    echo "Loading xsession script $script"
    . "$script"
fi

echo "X session wrapper complete, running session $@"

exec $@
```

It is clear that lightdm will run both `~/.xprofile` and `~/.xsession`. This files can be created to run personal startups scripts. For example, to change the background append the following:
```bash
~/.fehbg &
```
Where `~/.fehbg`:
```bash
#!/bin/sh
feh --no-fehbg --bg-fill 'path/to/image'
```
(Make sure `feh` is installed `pacman -S feh`).

## Configuring DWM
The configuration is done in the `~/.config/dwm/config.h ` file. There is not much to say about it, just read the code, this header file really is straight forward.
### Patching
Patching can fail. Go to [the dwm patches page](https://dwm.suckless.org/patches/) and download the ones you want.
1. After downloading the patch, run:
```bash
patch -p1 < /path/to/patch
```
2. If the automatic patching was successfull, recompile the changes:
```bash
make # To detect errors
sudo make install # To make the installation
```
3. To view the changes, log out and back in to restart the Xsession. (If default bindings were not changed, do `CTRL + SHIFT + Q`)

#### Manual patching
Sometimes, the automatic patching might fail. The likelihood of this happening increases with the amount of patches added.

When this happens, a `.rej` file created. Take a look inside, it will tell which lines could not be modified. Lines to append will have a "+" at the start of the line and lines to be deleted, a "-". Now it is **your** turn to find where the lines are supposed to go and which ones to remove in the pertinent file. Example:

The `patch` command shows an error and `dwm.c.rej` is created. Its contents:
```
--- dwm.c
+++ dwm.c
@@ -1222,6 +1340,12 @@ maprequest(XEvent *e)
 	static XWindowAttributes wa;
 	XMapRequestEvent *ev = &e->xmaprequest;
 
+	Client *i;
+	if (showsystray && (i = wintosystrayicon(ev->window))) {
+		sendevent(i->win, netatom[Xembed], StructureNotifyMask, CurrentTime, XEMBED_WINDOW_ACTIVATE, 0, systray->win, XEMBED_EMBEDDED_VERSION);
+		updatesystray(1);
+	}
+
 	if (!XGetWindowAttributes(dpy, ev->window, &wa))
 		return;
 	if (wa.override_redirect)
``` 
What to do now? Open `dwm.c` go to the line 1222 and look around for the lines that appear before and after the 6 "+" lines shown in the section. After locating `XMapRequestEvent *ev = &e->xmaprequest;` and `if (!XGetWindowAttributes(dpy, ev->window, &wa))`, simply add the new lines in between.

Patches will affect the `config.def.h` file. This additions must be moved into `config.h`. Diff both files to see what is new in `config.def.h` and yank or modify it in `config.h`. This is necessary as some new variables can be declared in the header file (depends on the patch).


#### Alpha
For patches like [alpha](https://dwm.suckless.org/patches/alpha/) to work, a compositor is needed.
```bash
sudo pacman -S picom
```
Run it in your autostart file. In this case, add the following line to `~/.xprofile` or `~/.xsession`:
```bash
picom &
```

#### Patches
- [bottomstack](https://dwm.suckless.org/patches/bottomstack/)
- [fullgaps](https://dwm.suckless.org/patches/fullgaps/)
- [viewontag](https://dwm.suckless.org/patches/viewontag/)
- [dwm-alpha-systray](https://github.com/bakkeby/patches/blob/master/dwm/dwm-alpha-systray-6.3_full.diff). Installing alpha and then systray and viceversa did not work (apparently these two patches do conflict). Thankfully this exists.

* [alpha](https://dwm.suckless.org/patches/alpha/)
*  [systray](https://dwm.suckless.org/patches/systray/)

### Status bar
There are multiple ways to configure what is shown in the status bar: by using a suckless tool called [slstatus](https://tools.suckless.org/slstatus/), by running a script that changes the name of the X root window, o by using a patch called [setstatus](https://dwm.suckless.org/patches/setstatus/).

These methods involve adding something to `~/.xprofile`. If your final build will have multiple window managers, it is recommended to install the [autostart](https://dwm.suckless.org/patches/autostart/) patch and run dwm-specific things from there.

#### slstatus
slstatus is easy to configure and use. Install it by:
```bash
git clone git://git.suckless.org/slstatus ~/.config/slstatus
cd ~/.config/slstatus && sudo make install
```
To run it, add the following line to the `~/.xprofile` file.
```bash
slstatus &
```
The configuration of what is shown is done in the `~/.config/slstatus/config.h` file.
For example, to display CPU, RAM and date, the argument struct can be populated this way:
```c
static const struct arg args[] = {
    /*function format               argument */
    { cpu_perc, " \uf4bc %s%% | ",    NULL },
    { ram_perc, "\ue266 %s%% - ",     NULL },
    { ram_used, "%s | ",              NULL },
    { datetime, "%s ", "%d/%m/%Y | %H:%M:%S" },
}
```
Additionally, if you want to do something else, like showing the number of pending updates, you can add a custom command:
```c
static const struct arg args[] = {
    /*function format               argument */
    { run_command, " %s updates |",    "{ timeout 20 checkupdates 2>/dev/null || true; } | wc -l" },
    { cpu_perc, " \uf4bc %s%% | ",    NULL },
    { ram_perc, "\ue266 %s%% - ",     NULL },
    { ram_used, "%s | ",              NULL },
    { datetime, "%s ", "%d/%m/%Y | %H:%M:%S" },
}
```
Though in this case you might not want to check for updates every second. For that I took inspiration from this [post](https://www.reddit.com/r/suckless/comments/kdsl1c/independently_updating_commands_in_slstatus/). And will implement the cron job.

#### xsetroot way
The [status bar](https://dwm.suckless.org/status_monitor/) is stored in the WM_NAME X11 property of the root window, which is managed by dwm. 
To change this name, simply run:
```bash
xsetroot -name "string"
```
In order to make this status bar show information periodically, the general practice is to create a script that autostarts and performs the refresh in a while loop. 
For example, inspired from [siduck](https://github.com/siduck/chadwm/blob/main/scripts/bar.sh):
```bash
#!/bin/sh

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

## st
The same philosophy applies to the simple terminal. Simply patch it. I just added scroll and alpha. Not much to comment.

## dmenu
Patches:
- [alpha](https://tools.suckless.org/dmenu/patches/alpha/)
- [center](https://tools.suckless.org/dmenu/patches/center/)
- [numbers](https://tools.suckless.org/dmenu/patches/numbers/)
- [dracula](https://tools.suckless.org/dmenu/patches/dracula/)
- [grid](https://tools.suckless.org/dmenu/patches/grid/)
- [gridnav](https://tools.suckless.org/dmenu/patches/gridnav/)

