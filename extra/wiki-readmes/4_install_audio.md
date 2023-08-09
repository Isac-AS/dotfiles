# Audio
This page focuses on audio configuration and some usefull additional information.
## Pipewire
The audio installation was done using pipewire. There was no need to do additional configurations, just install the following packages:
```bash
sudo pacman -S pipewire
sudo pacman -S wireplumber
sudo pacman -S pipewire-audio
sudo pacman -S pipewire-alsa
sudo pacman -S pipewire-pulse
sudo pacman -S pipewire-jack
sudo pacman -S pavucontrol
```
Arch Wiki pages:
- [pipewire](https://wiki.archlinux.org/title/PipeWire)
- [wireplumber](https://wiki.archlinux.org/title/WirePlumber)
- [ALSA (Advanced Linux Sound Architecture)](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)
- [JACK](https://wiki.archlinux.org/title/JACK_Audio_Connection_Kit)
- [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/) is a [GTK](https://en.wikipedia.org/wiki/GTK) based audio control tool.

## Media player control
Additionally, to get a better experience, use a media player controller like [playerctl](https://github.com/altdesktop/playerctl). Install it by running
```
sudo pacman -S playerctl
```
Now you can do basic stuff like:
```
# No need to explain what these do
playerctl play-pause
playerctl stop
playerctl previous
playerctl next
```

In order to bind these commands to xeys, install [`xbindkeys`](https://wiki.archlinux.org/title/Xbindkeys).
```bash
sudo pacman -S xbindkeys
```
Then create the blank `~/.xbindkeysrc` and add the key bindings there. For example:
```
"playerctl play-pause"
  XF86AudioPlay
```
The top line is the command and the bottom line is the key.
To know whick key is what, run `xev`, for it to be readble, do ` xev | grep keysym` and use the name that appears in the parenthesis.
```
state 0x0, keycode 36 (keysym 0xff0d, Return), same_screen YES,
```
Note that this could be used for anything, like spawning applications.

## Volume control
In a similar fashion volume can be controled with the `amixer` command, part of the `alsa-utils` package.
```bash
sudo pacman -S alsa-utils
```
Now, take a look at the `.xbindkeysrc` file so far.
```
"playerctl play-pause"
  XF86AudioPlay

"playerctl stop"
  XF86AudioStop

"playerctl previous"
  XF86AudioPrev

"playerctl next"
  XF86AudioNext

"amixer set Master 5%+"
  XF86AudioRaiseVolume

"amixer set Master 5%-"
  XF86AudioLowerVolume

"amixer set Master toggle"
  XF86AudioMute
```
Note: XF86AudioPlay in my keyboard is "FN+F9", XF86AudioStop is "FN+F10"...

## PC-speaker
[Arch Wiki](https://wiki.archlinux.org/title/PC_speaker). Some software, e.g. web browsers, editors and terminals, may produce beeps which may or may not be desired by the user. I was surprised and decided to disable it via `Xorg`. Run:
```bash
xset -b
```
This can be added to the startup file `~/.xprofile`.

