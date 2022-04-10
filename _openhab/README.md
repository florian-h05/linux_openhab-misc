# openHAB: scripts, tips & tricks

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [General Info](#general-info)
- [openHAB backup](#openhab-backup)
  - [How to setup](#how-to-setup)
- [NGINX reverse proxy](#nginx-reverse-proxy)
- [ufw Firewall](#ufw-firewall)
  - [IMPORTANT: ufw can break you openHAB KNX](#important-ufw-can-break-you-openhab-knx)
  - [IMPORTANT: ufw can block your openHAB HomeKit](#important-ufw-can-block-your-openhab-homekit)
  - [IMPORTANT: ufw can block the event broadcast from DoorBird Doorbells](#important-ufw-can-block-the-event-broadcast-from-doorbird-doorbells)
- [Monitoring](#monitoring)
- [Logging](#logging)


## General Info
***
Documentation for openHAB specific configuration files, like NGINX reverse proxy configuration, openHAB rules & scripts and openHAB guides.

openHAB configuration itself can be found at [florian-h05/openhab-conf](https://github.com/florian-h05/openhab-conf).


## openHAB backup
***
Backup _openHAB_ with the backup tool of ``openhab-cli`` to a path and use backup rotation.
Run [openhab-backup.bash](openhab-backup.bash) every week by _crontab_ and it deletes the backup from five weeks ago.

### How to setup
* line 8: set ``path`` to the backup path


## NGINX reverse proxy
***
NGINX website configuration for openHAB authorization & access control.
For additional information please have a look at the [official documentation](https://www.openhab.org/docs/installation/security.html#running-openhab-behind-a-reverse-proxy). This file also includes securing the frontail log viewer.

Frontail is reachable under [https://openhab/frontail](https://openhabianpi/frontail).

Please look at [this guide](/etc/nginx/sites-enabled/README.md).


## ufw Firewall
***
__Important information:__ A firewall is only a part of securing your server!
* Follow the firewall section of the [system setup guide](/_docs/openHABian_setup.md#firewall).
* Reload ufw: ```sudo ufw reload```

### IMPORTANT: ufw can break you openHAB KNX

When using the ``openHAB KNX binding``, you have to allow the traffic from your _IP Gateway_ to your _openHAB_:
* Get your interface name by executing ``ifconfig``, default is ``eth0``
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from <KNXgateway-ip> to any port 3671 proto udp comment 'openHAB - KNX Gatway'
  sudo ufw allow in on <interface-name> from <openHAB-ip> to any port 3671 proto udp comment 'openHAB - KNX'
  ```

### IMPORTANT: ufw can block your openHAB HomeKit

When using the [``openHAB HomeKit Integration``](https://www.openhab.org/addons/integrations/homekit/#homekit-add-on), you have to allow access to the HomeKit ports:
* Get your interface name by executing ``ifconfig``, default is ``eth0``
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from any to any port 9123 proto tcp comment 'openHAB - HomeKit'
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
  sudo ufw allow from <ip-of-your-doorbird> to any port 6524 proto udp comment 'openHAB - DoorBird Event Monitoring'
  ```

### IMPORTANT: ufw can block broadcast from Yamaha Amplifiers

```shell
sudo ufw allow from <ip-yamaha> to any port 52000 proto udp comment 'openHAB - Yamaha <name-yamaha>'
```

## Monitoring
***
Monitor your items and visualize their history.

InfluxDB allows you to persist and query states and Grafana visualizes them for you.
You can find my setup [here](/_monitoring/README.md) or you install InfluxDB & Grafana using the _openhabian-config_ tool.

## Logging
***
To change logging behaviour, have a look at `$openhab-userdata/etc/log4j2.xml`.
