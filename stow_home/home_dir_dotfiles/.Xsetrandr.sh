#!/bin/sh
xrandr --output DP-0 --mode 2560x1440 --rate 165 --primary
xrandr --output DP-2 --mode 2560x1440 --rate 75 --above DP-0
xrandr --output HDMI-0 --mode 1920x1080 --rate 120 --left-of DP-0
xrandr --output DP-4 --rotate right --mode 1920x1080 --rate 165 --pos 4480x960
