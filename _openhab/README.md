# openHAB: scripts, tips & tricks

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [1. General Info](#1-general-info)
- [2. openHAB backup](#2-openhab-backup)
  - [How to setup](#how-to-setup)
- [3. NGINX reverse proxy](#3-nginx-reverse-proxy)
- [4. ufw firewall](#4-ufw-firewall)
  - [IMPORTANT: ufw can break you openHAB KNX](#important-ufw-can-break-you-openhab-knx)
  - [IMPORTANT: ufw can block your openHAB HomeKit](#important-ufw-can-block-your-openhab-homekit)
  - [IMPORTANT: ufw can block the event broadcast from DoorBird Doorbells](#important-ufw-can-block-the-event-broadcast-from-doorbird-doorbells)
- [4. Failover](#4-failover)
- [6. Monitoring](#6-monitoring)
- [7. Logging](#7-logging)


## 1. General Info
***
Documentation for openHAB specific configuration files, like NGINX reverse proxy configuration, openHAB rules & scripts and openHAB guides.


## 2. openHAB backup
***
Backup _openHAB_ with the backup tool of ``openhab-cli`` to a path and use backup rotation.
Run [openhab-backup.bash](openhab-backup.bash) every week by _crontab_ and it deletes the backup from five weeks ago.

### How to setup
* line 8: set ``path`` to the backup path


## 3. NGINX reverse proxy
***
NGINX website configuration for openHAB authorization & access control.
For additional information please have a look at the [official documentation](https://www.openhab.org/docs/installation/security.html#running-openhab-behind-a-reverse-proxy). This file also includes securing the frontail log viewer.

Frontail is reachable under [https://openhab/frontail](https://openhabianpi/frontail).

Please look at [this guide](/etc/nginx/sites-enabled/README.md).


## 4. ufw firewall
***
__Important information:__ A firewall is only a part of securing your server!

The following commands help you to setup your ufw firewall:
* This requires the [system setup guide](/_docs/openHABian_setup.md).
* Block access to native openHAB ports: ``sudo ufw deny 8080/tcp comment openHAB-native`` and ``sudo ufw deny 8443/tcp comment openHAB-native``
* Reload ufw: ```sudo ufw reload```

### IMPORTANT: ufw can break you openHAB KNX

When using the ``openHAB KNX binding``, you have to allow the traffic from your _IP Gateway_ to your _openHAB_:
* Get your interface name by executing ``ifconfig``, default is ``eth0``
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from <KNXgateway-ip> to any port 3671 proto udp comment openHAB-KNX_Gatway``
  sudo ufw allow in on <interface-name> from <openHAB-ip> to any port 3671 proto udp comment openHAB-KNX
  ```

### IMPORTANT: ufw can block your openHAB HomeKit

When using the [``openHAB HomeKit Integration``](https://www.openhab.org/addons/integrations/homekit/#homekit-add-on), you have to allow access to the HomeKit ports:
* Get your interface name by executing ``ifconfig``, default is ``eth0``
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from any to any port 9123 proto tcp comment openHAB_HomeKit
  ```
* You can chech the openHAB HomeKit mDNS advertiser with the iOS App [Discovery](https://apps.apple.com/de/app/discovery-dns-sd-browser/id305441017): 
  * Open the entry **hap._tcp.** and search for your openHAB HomeKit bridge
  * Open the entry of your openHAB HomeKit bridge
    * Check the IP address on top of the page
    * Check **sf =**, a value of **1** means, that it is unpaired, **0** means it is already paired.


__Information:__ you should look at ``/var/log/ufw.log`` for failed requests and check for ip addresses of your _openHAB_ devices.
For example I checked the logs and found out, that my _Yamaha MusicCast_ devices were trying to connect to ``51200/udp``, so I added a rule for them in ufw.

### IMPORTANT: ufw can block the event broadcast from DoorBird Doorbells

When using the [``openHAB DoorBird Binding``](https://www.openhab.org/addons/bindings/doorbird/#doorbird-binding), you have to allow the broadcast traffic for event monitoring:
* ```shell
  sudo ufw allow from <ip-of-your-doorbird> to any port 6524 proto udp comment DoorBird_EventMonitoring
  ```

### IMPORTANT: ufw can block broadcast from Yamaha Amplifiers

```shell
sudo ufw allow from <ip-yamaha> to any port 52000 proto udp comment 'openHAB - Yamaha <name-yamaha>'
```

## 4. Failover
***
Protect your smart home from an openHAB crash.

Although openHAB and Debian are running extremely stable, you never can be prepared well enough for crash. So you could need a failover, that keeps your smart home running when your main openHAB crash or is not reachable. 

For easy backup and restore I regularly create images of my openHAB system with _Acronis True Image_ and during this time my openHAB is of course not reachable. 

Therefore, you find a failover for openHAB in [this folder](failover-system). For further configuration, please have a look at [this guide](failover-system/README.md).


## 6. Monitoring
***
Monitor your items and visualize their history.

InfluxDB allows you to persist and query states and Grafana visualizes them for you.
You can find a my setup [here](/_monitoring/README.md).

## 7. Logging
***
To change logging behaviour, have a look at `$openhab-userdata/etc/log4j2.xml`.