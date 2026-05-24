#!/bin/sh
cap=$(cat /sys/class/power_supply/bq27411-0/capacity)
status=$(cat /sys/class/power_supply/bq27411-0/status)

if [ "$status" = "Charging" ] && [ "$cap" -eq 100 ]; then
    cap=$(upower -i /org/freedesktop/UPower/devices/battery_bq27411_0 | awk '/percentage/{gsub("%","",$2); print int($2)}')
fi

if [ "$status" = "Charging" ]; then
    echo "⚡ ${cap}%"
else
    echo "🔋 ${cap}%"
fi
