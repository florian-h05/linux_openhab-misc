#!/bin/bash
# Script: pi-temp.bash
# Purpose: Display CPU and GPU temprature from SoC of Raspberry pi
# Author: Florian Hotze

cpu=$(</sys/class/thermal/thermal_zone0/temp)
echo "$(date) at $(hostname)"
echo ""
echo "CPU --> $((cpu/1000))'C"
echo "GPU --> $(/opt/vc/bin/vcgencmd measure_temp)"