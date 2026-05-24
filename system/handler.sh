#!/bin/sh

export SWAYSOCK=$(ls /run/user/10000/sway-ipc.*.sock 2>/dev/null | head -n 1)

STATE_FILE=/tmp/sway_screen_state

if [ -f "$STATE_FILE" ]; then
    su kuntal -c 'swaymsg "output DSI-1 dpms on"'
    rm -f "$STATE_FILE"
else
    su kuntal -c 'swaymsg "output DSI-1 dpms off"'
    touch "$STATE_FILE"
fi
