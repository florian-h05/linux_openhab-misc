#!/bin/bash
#########################################################################
# Script: openhab-backup.sh
# Purpose: Backup the openhab-configuration and remove the backup from five weeks ago.
# Author: Florian Hotze
# License: MIT License
#########################################################################

BACKUP= # Insert backup path here

if [ "$EUID" -ne 0 ]; then echo_red "Please run as root" && exit 1; fi

# import today's date
YMD=$(date +"%F")
# import the date from five weeks ago
FWA=$(date --date '5 weeks ago' +%F)

echo "Stopping the openHAB instance ..."
systemctl stop openhab

echo "Starting backup to ${BACKUP} ....."

# execute the openhab built-in backup tool
if openhab-cli backup --full "${BACKUP}"/openhab-backup_"${YMD}"; then echo "SUCCESS: Backed up openHAB."
else
  echo "ERROR: openHAB backup failed!"
fi


echo "Removing backup from five weeks ago ....."

# remove the backup from five weeks ago
if rm "${BACKUP}/openhab-backup_${FWA}.zip"; then echo "SUCCESS: Deleted backup from five weeks ago!"; else echo "ERROR: Failed to delete backup from five weeks ago!"; fi

echo Starting the openHAB instance ...
if systemctl start openhab; then echo "SUCCESS: openHAB has started successful.";
else
  echo "ERROR: Failed to start openHAB!"
  exit 1
fi
