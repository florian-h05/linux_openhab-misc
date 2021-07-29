# openHAB: scripts, tips & tricks

## Table of Contents
1. [General Info](#general-info)
2. [openhab-backup.bash](#openhab-backup)
3. [NGINX reverse proxy](#nginx-reverse-proxy)
4. [ufw firewall](#ufw-firewall)
5. [shaddow.py script](#shaddow-script-python)
6. [failover](#failover)
7. [openhab-log-influxdb.py](#influxdb-log-python)
8. [InfluxDB & Grafana](#influxdb-grafana)

***
## General Info
Documentation for openHAB specific configuration files, like NGINX reverse proxy configuration, openHAB rules & scripts and openHAB guides.

***
## openHAB backup
Backup _openHAB_ with the backup tool of ``openhab-cli`` to a path and use backup rotation.
Run [openhab-backup.bash](../openhab/openhab-backup.bash) every week by _crontab_ and delete the backup from five weeks ago.

### How to setup:
* line 8: set ``path`` to the backup path

***
## NGINX reverse proxy
NGINX website configuration for openHAB authorization & access control.
For additional information please have a look at the [official documentation](https://www.openhab.org/docs/installation/security.html#running-openhab-behind-a-reverse-proxy). This file also includes securing the frontail log viewer.

Frontail is reachable under [https://openhabianpi/frontail](https://openhabianpi/frontail).

### How to setup:
Please look at [this guide](../openhab/reverse-proxy/REVERSE-PROXY.md).

***
## ufw firewall
### __Important information:__ A firewall is only a part of securing your server!

The following commands help you to setup your ufw firewall:
* install ufw: ``sudo apt install ufw``
* __important:__ allow ufw, otherwise you lock yourself out: ``sudo ufw allow ssh``
* _(set up the default policies: ``sudo ufw default deny INCOMING`` and ``sudo ufw default allow OUTGOING``)_
* block access to native openHAB ports: ``sudo ufw deny 8080/tcp comment openHAB-native`` and ``sudo ufw deny 8443/tcp comment openHAB-native``
* allow access to your reverse proxy: ``sudo ufw allow https comment openHAB-nginx``
* allow IGMP protocol:
  * ``sudo ufw allow in proto udp to 224.0.0.0/4``
  * add to ``/etc/ufw/before.rules``: 
   
    ```
    # allow IGMP
    -A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
    -A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT
    ```
* start ufw: ```sudo ufw enable```

***
### IMPORTANT: ufw can break you openHAB KNX

When using the ``openHAB KNX binding``, you have to allow the traffic from your _IP Gateway_ to your _openHAB_:
* get your interface name by executing ``ifconfig``, default is ``eth0``
* ``sudo ufw allow in on <interface-name> from <KNXgateway-ip> to any port 3671 proto udp comment openHAB-KNX_Gatway``
* ``sudo ufw allow in on <interface-name> from <openHAB-ip> to any port 3671 proto udp comment openHAB-KNX``

***
### IMPORTANT: ufw can block your openHAB HomeKit

When using the ``openHAB HomeKit Integration``, you have to allow access to the HomeKit ports:
* get your interface name by executing ``ifconfig``, default is ``eth0``
* ``sudo ufw allow in on <interface-name> from any to any port 9124 proto udp comment openHAB_HomeKit``

***
__Information:__ you should look at ``/var/log/ufw.log`` for failed requests and check for ip addresses of your _openHAB_ devices.
For example I checked the logs and found out, that my _Yamaha MusicCast_ devices were trying to connect to ``51200/udp``, so I added a rule for them in ufw.

***
## shaddow script python
### This script was originally written by [@pmpkk](https://github.com/pmpkk) at [openhab-habpanel-theme-matrix](https://github.com/pmpkk/openhab-habpanel-theme-matrix).
I only modified it to work with _Python 3_ and the new _InfluxDB 2.x_. 

[shaddow.py](../openhab/shaddow/shaddow.py) generates a _.svg_ image to illustrate where the sun is currently positioned, which site of the house is facing the sun and where the shaddow of your house is.
I added the position of the moon to the image. 

***
### How to setup:
Please look at [this guide](../openhab/shaddow/README.md).

***
## failover
### Protect your smart home from an openHAB crash.

Although openHAB and Debian are running extremely stable, you never can be prepared well enough for crash. So you could need a failover, that keeps your smart home running when your main openHAB crash or is not reachable. 

For easy backup and restore I regularly create images of my openHAB system with _Acronis True Image_ and during this time my openHAB is of course not reachable. 

Therefore, you find a failover for openHAB in [this folder](../openhab/failover-system). For further configuration, please have a look at [this guide](../openhab/failover-system/README.md).

***
## influxdb log python
### A log for your smart home with [openhab-log-influxdb.py](../openhab/openhab-log-influxdb.py).

Create a log of your smart home in InfluxDB with the following data:
* log message
* device
* temperature
* windspeed
* brightness
* rain
* elevation
* azimuth

### How to setup:
* line 30: set ``base_url`` to _openHAB_ hostname/address and append ``/rest``
* lines 34 to 39: setup _InfluxDB_
* lines 52 to 57: set your _openHAB_ items in ``items.get('<itemname>').state``

***
## InfluxDB Grafana
### Monitor your items and visualize their history.

InfluxDB allows you to persist and query states and Grafana visualizes them for you.
You can find a my setup [here](../openhab/influxdb_grafana).