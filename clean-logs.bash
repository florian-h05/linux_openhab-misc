#!/bin/bash
# Script: clean-logs.bash
# Purpose: Delete rotated and .gz logs from /var/log
# Use: Clean the logs on tmpfs to avoid /var/log as tmpfs filling your RAM.
# Author: Florian Hotze

if [[ "$(whoami)" != root ]]
then 
  echo "You must run this script as root or with sudo."
  exit 1
fi

find -L /var/log -type f -regex ".*\.gz$" -delete
find -L /var/log -type f -regex ".*\.[0-9]$" -delete
if [ -d "/var/log/sbfspot.3" ]
then
  find -L /var/log/sbfspot.3 -type f -mtime +2 -delete
fi
