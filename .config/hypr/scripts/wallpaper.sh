#!/bin/bash
WALLPAPER_DIR="/home/kaldir/Pictures/Backgrounds"
SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | rofi -dmenu  --prompt "Select Wallpaper:")
swww img "$SELECTED_WALLPAPER" --transition-type wipe --transition-angle 30 --transition-fps 60 --transition-duration .5
wal -i "$SELECTED_WALLPAPER" -n --cols16
swaync-client --reload-css
