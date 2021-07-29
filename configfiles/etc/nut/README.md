# NUT - Network UPS Tools

***
## Table of Contents
1. [Requirements](#requirements)
3. [Installation](#installation)

***
## Requirements:
* an UPS with an USB port, I use an _Eaton 3S 700_
* a Mail Transfer Agent with mailx

***
## Installation
* Install [nut](https://networkupstools.org) with:
  ```shell
  sudo apt install nut
  ```
* Use the files from this folder
* Configure NUT:
  * _ups.conf_: Set up UPS drive, port and name in lines 138-141.
  * _upsd.conf_: Set up listening interface from line 30.
  * _upsd.users_: Manage and setup of users and permissions.
  * _upsmon.conf_: Set up which UPS to use with password and settings in line 82.
  * _upsched-cmd_: Replace ```<email>``` with your e-mail address.
* Adjust permissions:
  ```shell
  sudo chown -R root:nut /etc/nut/*
  sudo chmod -R 640 /etc/nut/*
  sudo chmod 750 -R /etc/nut/upssched-cmd
  ```
* Create _upssched_ folder for _PIPEFN_ and _LOCKFN_ from _upssched_:
  ```shell
  sudo mkdir /etc/nut/upssched
  sudo chown -R root:nut /etc/nut/upssched
  sudo chmod 770 -R /etc/nut/upssched
  ```
* Make sure, that systemd-service _nut-server_ is always running:
  ```shell
  sudo crontab -e
  # then add to crontab:
  * * * * * sudo systemctl start nut-server
  ```
