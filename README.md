# Linux & openHAB: nice-to-haves, configuration and  miscellaneous


### [signal-cli-rest-api](https://github.com/bbernhard/signal-cli-rest-api) client
### small scripts which can help you a lot

***
## Table of Contents
1. [General Info](#general-info)
2. [signal-cli-rest-api client](#signal-client)
3. [Backup and restore script](#backup-restore-bash-script)
4. [openHAB](#openhab)
5. [custom configuration](#custom-configuration)

## General Info
***
This repository is a collection of scripts and configuration files I use on my personal Linux/openHAB system.
### Contributing
Ideas, issues and pull requests are welcome!

## signal client
***
#### A small bash client for the [signal-cli REST API](https://github.com/bbernhard/signal-cli-rest-api) from [@bbernhard](https://github.com/bbernhard).
#### [Signal](https://signal.org/) is a secure and trusted [open-source](https://github.com/signalapp) messenger.

Currently it supports:
* sending messages to one recipient
* listing identities
* trusting identities
* integrated address book

### How to setup:
Please have a look at [this guide](/doc/SIGNAL-CLIENT.md).


## backup-restore bash script
***
### A backup and restore utility

This script is collecting folders and files defined in the [script itself](backup_restore.bash). These folders and files are copied to a temporary folder and this folder is compressed as ```.tar.gz``` on your backup destination

Information about what is backed up can be found in the [script itself](backup_restore.bash).
### How to setup:
Please have a look at [this guide](/doc/BACKUP_RESTORE.md).

## openhab
***
The [openhab folder](openhab) contains ```scripts``` and openHAB specific files.
More information can be found in [this guide](/doc/OPENHAB.md).
#### My __personal highlight__ is [shaddow.py](openhab/shaddow.py), which was originally written by [@pmpkk](https://github.com/pmpkk) and published [here](https://github.com/pmpkk/openhab-habpanel-theme-matrix). My fork of his script is supported by ```Python 3``` and it is using the all-new ```Flux query-language``` of ```InfluxDB 2.x```. It creates a realtime image of your house's outline with the location of sun, moon and your house's shaddow.

## custom configuration
***
* ```systemd``` configuration with decreased exposure levels
* [fail2ban](https://github.com/fail2ban/fail2ban) configuration files

### How to setup:
A setup guide is provided inside most configuration files.
