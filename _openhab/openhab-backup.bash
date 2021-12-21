#!/bin/bash
# Script: openhab-backup.sh
# Purpose: Backup the openhab-configuration and remove the backup from five weeks ago.
# Copyright (C) 2021 Florian Hotze under MIT License
# Info: all dates are formatted as YYYY-MM-DD

# path for backup
path=

# import today's date
YMD=$(date +"%F")
# import the date from five weeks ago
FWA=$(date --date '5 weeks ago' +%F)

echo "Stopping the openHAB instance ..."
sudo systemctl stop openhab

echo "Starting backup to ${path} ....."

# execute the openhab built-in backup tool
if sudo openhab-cli backup --full "${path}"/openhab-backup_"${YMD}"; then echo "SUCCESS: backing up openHAB."
else 
  echo "ERROR: openHAB backup failed!"
fi


echo Removing backup from five weeks ago .....

# remove the backup from five weeks ago
if sudo rm "${path}"/openhab-backup_"${FWA}".zip; then echo "SUCCESS: Deleted backup from five weeks ago!"; else "ERROR: Deleting backup from five weeks ago failed."; fi

echo Starting the openHAB instance ...
if sudo systemctl start openhab; then echo "SUCCESS: openHAB has started successful.";
else
  echo "ERROR: failed to start openHAB!"
  exit 1
fi
