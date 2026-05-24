#!/bin/sh
cap=$(cat /sys/class/power_supply/bq27411-0/capacity)
status=$(cat /sys/class/power_supply/bq27411-0/status)

if [ "$cap" -gt 95 ] && [ "$status" = "Charging" ]; then
    cap=$(awk -v now=$(cat /sys/class/power_supply/bq27411-0/charge_now) \
              -v design=$(cat /sys/class/power_supply/bq27411-0/charge_full_design) \
              'BEGIN {printf "%d", (now/design)*100}')
fi

if [ "$status" = "Charging" ]; then
    echo "⚡ ${cap}%"
else
    echo "🔋 ${cap}%"
fi
