#!/bin/bash
# Script: openhab-backup.bash
# Purpose: Run openHAB's backup tool and save the backup to a network mount with rotation of old backups.
# Author: Florian Hotze
# License: MIT

# Backup path
BACKUP_DEST=

# Today as YYYY-MM-DD
YMD=$(date +"%F")
# Six weeks ago as YYYY-MM-DD
SWA=$(date --date '6 weeks ago' +%F)

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to do this." 1>&2
    exit 1
fi

echo -n "Backing up openHAB ... "
BACKUP_SRC="/var/lib/openhab/backups/openhab-backup_$YMD.zip"
if sudo openhab-cli backup "$BACKUP_SRC" > /dev/null; then echo "DONE"
else
  echo "FAILED"
  exit 1
fi

echo -n "Mounting ${BACKUP_DEST} ... "
if sudo mount "$BACKUP_DEST"; then echo "DONE"
else
  echo "FAILED"
  exit 1
fi

echo -n "Moving backup into $BACKUP_DEST ... "
if sudo mv "$BACKUP_SRC" "$BACKUP_DEST/openhab-backup_$YMD.zip"; then echo "DONE"; else echo "FAILED"; fi

echo -n "Removing backup from six weeks ago ... "
if sudo rm "$BACKUP_DEST"/openhab-backup_"$SWA".zip; then echo "DONE"; else echo "FAILED"; fi

echo -n "Unmounting $BACKUP_DEST ... "
if sudo umount "$BACKUP_DEST"; then echo "DONE"
else
  echo "FAILED"
  exit 1
fi
