# Linux & openHAB: nice-to-haves, configuration and  miscellaneous


### [signal-cli-rest-api](https://github.com/bbernhard/signal-cli-rest-api) client
### small scripts which can help you a lot

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [1. General Info](#1-general-info)
- [2. Signal client](#2-signal-client)
- [3. backup-restore bash script](#3-backup-restore-bash-script)
- [4. openHAB](#4-openhab)
- [5. NUT UPS](#5-nut-ups)
- [6. _systemd_ service files](#6-systemd-service-files)
- [7. _/var/log_ in _tmpfs_ on Raspberry Pi](#7-varlog-in-tmpfs-on-raspberry-pi)

## 1. General Info
***
This repository is a collection of scripts and configuration files I use on my personal Linux/openHAB system.

## 2. Signal client
***
A small bash client for the [signal-cli REST API](https://github.com/bbernhard/signal-cli-rest-api) from [@bbernhard](https://github.com/bbernhard).
[Signal](https://signal.org/) is a secure and trusted [open-source](https://github.com/signalapp) messenger.

Currently it supports:
* sending messages to one recipient
* listing identities
* trusting identities
* integrated address book

Please have a look at [this guide](SIGNAL-CLIENT.md).


## 3. backup-restore bash script
***
__A backup and restore utility__

This script is collecting folders and files defined in the [script itself](backup_restore/backup_restore.bash). These folders and files are copied to a temporary folder and this folder is compressed as ```.tar.gz``` on your backup destination

Information about what is backed up can be found in the [script itself](backup_restore/backup_restore.bash).

Please have a look at [this guide](backup_restore/BACKUP_RESTORE.md).

## 4. openHAB
***
The [openhab folder](openhab) contains ```scripts``` and openHAB specific files.
More information can be found in [this guide](openhab/README.md).

My __personal highlight__ is [shaddow.py](openhab/shaddow/shaddow.py), which was originally written by [@pmpkk](https://github.com/pmpkk) and published [here](https://github.com/pmpkk/openhab-habpanel-theme-matrix). My fork of his script is supported by ```Python 3``` and it is using the all-new ```Flux query-language``` of ```InfluxDB 2.x```. It creates a realtime image of your house's outline with the location of sun, moon and your house's shaddow.

## 5. NUT UPS
***
Setup guide for [NUT](https://networkupstools.org), the software to control your uninterruptable power source.

Please have a look at [this guide](network-ups-tools/README.md).

## 6. _systemd_ service files
***
A collection of custom _systemd_ service files with improved security level.

Please have a look at [this folder](systemd_service-custom).

## 7. _/var/log_ in _tmpfs_ on Raspberry Pi
***
Continous writing to an SD card can reduce the lifetime of the card. To reduce the load on the SD card, _var/log_ can be stored in the RAM with _tmpfs_.

Please have a look at [this guide](tmpfs_var-log/README.md).