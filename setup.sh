#!/bin/sh

sudo apk add sway waybar foot brightnessctl yad wofi squeekboard acpid

mkdir -p ~/.config

cp -r sway ~/.config/
cp -r waybar ~/.config/

sudo cp system/acpid.service /etc/systemd/system/
sudo cp system/handler.sh /etc/acpi/

sudo systemctl enable acpid
