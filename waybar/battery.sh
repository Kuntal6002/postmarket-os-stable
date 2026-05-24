#!/bin/sh
cap=$(cat /sys/class/power_supply/bq27411-0/capacity)
status=$(cat /sys/class/power_supply/bq27411-0/status)

if [ "$status" = "Charging" ]; then
    echo "⚡ ${cap}%"
else
    echo "🔋 ${cap}%"
fi
