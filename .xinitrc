#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Custom

# Trackpoint/Touchpad 
trackpointID=$(xinput list --id-only 'Elan TrackPoint')
touchpadID=$(xinput list --id-only 'Elan Touchpad')
xinput --set-prop $trackpointID 'libinput Accel Speed' .3
xinput --set-prop $trackpointID 'libinput Accel Profile Enabled' 0, 1 
xinput --set-prop $touchpadID 'libinput Accel Speed' 1 
xinput --set-prop $touchpadID 'libinput Accel Profile Enabled' 0, 1 
xinput --set-prop $touchpadID 'libinput Natural Scrolling Enabled' 1 

# swap caps and escape for prime vim goodness
setxkbmap -option caps:swapescape

# dual monitor
xrandr --output eDP1 --primary --mode 1920x1080 --rotate normal --output HDMI2 --mode 1920x1080 --rotate normal --right-of eDP1 

# Fix sluggish repeat key speed
xset r rate 180 25

feh --bg-fill ~/dotfiles/wallpapers/butterfly.jpg &
picom &
polybar default &
exec i3
# sxhkd &
# exec bspwm
