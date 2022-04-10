# Linux & openHAB: nice-to-haves, configuration and  miscellaneous

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [General Info](#general-info)
- [Signal client](#signal-client)
- [backup-restore bash script](#backup-restore-bash-script)
- [openHAB](#openhab)
- [My openHABian Setup](#my-openhabian-setup)
- [NUT UPS](#nut-ups)
- [_systemd_ service files](#systemd-service-files)

***
## General Info

This repository is a collection of scripts and configuration files I use in connection with my smart home environment.

Folders starting with an underscore, e.g. `_monitoring` are feature folders.

Folders without an underscore, e.g. `etc` follow the Debian folder structure and represent my additions to the basic [openHABian](https://www.openhab.org/docs/installation/openhabian.html#openhabian-hassle-free-openhab-setup).

***
## Signal client

A small bash client for the [signal-cli REST API](https://github.com/bbernhard/signal-cli-rest-api) from [@bbernhard](https://github.com/bbernhard).
[Signal](https://signal.org/) is a secure and trusted [open-source](https://github.com/signalapp) messenger.

Currently it supports:
* sending messages to one recipient
* listing identities
* trusting identities
* integrated address book

Please have a look at [this guide](SIGNAL-CLIENT.md).

***
## backup-restore bash script

__A backup and restore utility__

This script is collecting folders and files defined in the [script itself](_backup_restore/backup_restore.bash). These folders and files are copied to a temporary folder and this folder is compressed as ```.tar.gz``` on your backup destination

Information about what is backed up can be found in the [script itself](_backup_restore/backup_restore.bash).

Please have a look at [this guide](_backup_restore/BACKUP_RESTORE.md).

***
## openHAB

The [openhab folder](_openhab) contains things related to openHAB.
More information can be found in [this guide](_openhab/README.md).

***
## My openHABian Setup
My openHABian Setup is documented at [openHABian Setup](_docs/openHABian_setup.md).

***
## NUT UPS

Setup guide for [NUT](https://networkupstools.org), the software to control your uninterruptable power source.

Please have a look at [this guide](/etc/nut/README.md).

***
## _systemd_ service files

A collection of custom _systemd_ service files with improved security level.

Please have a look at [this folder](/etc/systemd/system/README.md).
