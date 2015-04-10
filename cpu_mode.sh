#!/bin/bash
# cpu_mode.sh
# Copyright 2015 wellingtons, github.com/wellingtons
#
# Usage: ./cpu_mode.sh <mode>
# Where mode is: auto, max, min, user, conservative
# Run as root, i.e sudo cpu_mode.sh
#
# To see your modes available go: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
# Get command line argument for mode selection
if [ "$1" = "auto" ] ; then MODE=ondemand
elif [ "$1" = "max" ] ; then MODE=performance
elif [ "$1" = "min" ] ; then MODE=powersave
elif [ "$1" = "user" ] ; then MODE=userspace
elif [ "$1" = "conservative" ] ; then MODE=conservative # To check your cpu for support cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
else
echo -e "No valid mode selected\nUsage $0 <auto,min,max,user,conservative>\nExiting!"
exit 1
fi

#
# check for root
#
if [ "$(id -u)" != "0" ]; then echo -e "Script $0 must be run as root\nExiting!" 1>&2
exit 1
fi

# debug
echo "CPU mode selected is: $MODE"
CPU_CORES=$(grep --count processor /proc/cpuinfo) # Outputs number of cores
#
# debug
echo "Number of cores is: $CPU_CORES"
#
# Because core 0 is the first core subtract 1 from the total
let CPU_CORES=CPU_CORES-1

# Loop through all available cpu cores assiging scailing mode to governor
LOOP_COUNT=0
while [ $LOOP_COUNT -le $CPU_CORES ]; do
echo $MODE > /sys/devices/system/cpu/cpu$LOOP_COUNT/cpufreq/scaling_governor
#
# give output
#
MODE_DISPLAY=$(cat /sys/devices/system/cpu/cpu$LOOP_COUNT/cpufreq/scaling_governor)
echo "CPU Core $LOOP_COUNT is mode: $MODE_DISPLAY" 
let LOOP_COUNT+=1
done
