# NUT - Network UPS Tools

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [1. Requirements](#1-requirements)
- [2. Installation](#2-installation)

***
## 1. Requirements
* an UPS with an USB port, I use an _Eaton 3S 700_
* a Mail Transfer Agent with mailx

***
## 2. Installation
* Install [nut](https://networkupstools.org) with:
  ```shell
  sudo apt install nut
  ```
* Configure NUT:
  * [_ups.conf_](/etc/nut/ups.conf): Set up UPS drive, port and name in lines 138-141.
  * [_upsd.conf_](/etc/nut/upsd.conf): Set up listening interface from line 30.
  * [_upsd.users_](/etc/nut/upsd.users): Manage and setup of users and permissions.
  * [_upsmon.conf_](/etc/nut/upsmon.conf): Set up which UPS to use with password and settings in line 82.
  * [_upsched-cmd_](/etc/nut/upssched-cmd): Setup ```EMAIL=``` with your e-mail address.
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
* Enable all services for autostart:
  ```shell
  sudo systemctl enable nut-server
  sudo systemctl enable nut-client
  sudo systemctl enable nut-monitor
  ```
* Make sure, that systemd-service _nut-server_ is always running:
  ```shell
  sudo crontab -e
  # then add to crontab:
  */2 * * * * sudo systemctl start nut-server
  ```

***
## Firewall
Allow external client through _ufw_:
``` bash
sudo ufw allow in from <client-ip> to any port 3493 proto tcp comment 'network ups tools - <client-name>'
```