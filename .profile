PATH="$PATH:$HOME/.local/bin"
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec seatd-launch sway
fi
