# openHAB: scripts, tips & tricks

## General Info

Documentation for openHAB specific configuration files, like NGINX reverse proxy configuration, openHAB rules & scripts and openHAB guides.

openHAB configuration itself can be found at [florian-h05/openhab-conf](https://github.com/florian-h05/openhab-conf).

## openHAB backup

Backup _openHAB_ with the backup tool of ``openhab-cli`` to a path and use backup rotation.
Run [openhab-backup.bash](openhab-backup.bash) every week by _crontab_ and it deletes the backup from five weeks ago.

### Setup

Set `path` to the backup path in line 8.

## NGINX reverse proxy

NGINX website configuration for openHAB authorization & access control.

Please read the openHAB documentation [Running openHAB behind a reverse proxy](https://www.openhab.org/docs/installation/security.html#running-openhab-behind-a-reverse-proxy).

Just add this section to your NGINX configuration file to access Frontail via the reverse proxy:

```nginx
This file also includes securing the frontail log viewer.
    # reverse proxy for frontail
    location /frontail {
        limit_except GET {
           deny all;
        }
        proxy_set_header Host                   $http_host;
        proxy_set_header X-Real-IP              $remote_addr;
        proxy_set_header X-Forwarded-For        $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto      $scheme;
        proxy_set_header Connection             "upgrade";
        proxy_set_header Upgrade                $http_upgrade;
        proxy_pass                              http://localhost:9001/frontail;
    }
```

## ufw Firewall

ufw is a simple firewall configuration tool for Linux.
It is installed by default on Debian and Ubuntu and can be used to allow or block traffic to and from your _openHAB_ server.

When using ufw, you have to open a few ports for your _openHAB_ server to work properly.

### IMPORTANT: ufw can break you openHAB KNX

When using the [openHAB KNX binding](https://www.openhab.org/addons/bindings/knx), you have to allow the traffic from your _IP Gateway_ to your _openHAB_:

* Get your interface name by executing `ifconfig`, default is `eth0`.
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from <KNXgateway-ip> to any port 3671 proto udp comment 'openHAB - KNX IP'
  ```

### IMPORTANT: ufw can block your openHAB HomeKit

When using the [openHAB HomeKit Integration](https://www.openhab.org/addons/integrations/homekit), you have to allow access to the HomeKit ports:

* Get your interface name by executing `ifconfig`, default is `eth0`.
* Then execute:
  ```shell
  sudo ufw allow in on <interface-name> from any to any port 9123 proto tcp comment 'openHAB - HomeKit'
  ```
* You can check the openHAB HomeKit mDNS advertisement with the iOS App [Discovery](https://apps.apple.com/de/app/discovery-dns-sd-browser/id305441017): 
  * Open the entry **hap._tcp.** and search for your openHAB HomeKit bridge
  * Open the entry of your openHAB HomeKit bridge
    * Check the IP address on top of the page
    * Check **sf =**, a value of **1** means, that it is unpaired, **0** means it is already paired.


__Information:__ you should look at ``/var/log/ufw.log`` for failed requests and check for ip addresses of your _openHAB_ devices.

### IMPORTANT: ufw can block the event broadcast from DoorBird Doorbells

```shell
sudo ufw allow from <ip-of-doorbird> to any port 6524 proto udp comment 'openHAB - DoorBird Event Monitoring'
 ```

### IMPORTANT: ufw can block event broadcast from Yamaha Amplifiers

```shell
sudo ufw allow from <ip-of-yamaha> to any port 52000 proto udp comment 'openHAB - Yamaha <name-yamaha>'
```

## Monitoring

openHAB allows to store historic states and forecasts in a persistence service.

InfluxDB is a time-series database and can be used as a persistence service in openHAB.
Grafana is a visualization tool and can be used to display the data stored in InfluxDB - but keep in mind that openHAB Main UI also has built-in charts and graphs.
You can find my setup [here](/_monitoring/README.md) or you install InfluxDB & Grafana using the _openhabian-config_ tool.
