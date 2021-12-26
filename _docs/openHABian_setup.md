# openHABian setup & changes

This guide describes my personal openHABian setup.

***
## Table of Contents


***
## Networking

### Interface configuration
Restart the networking service: `sudo systemctl restart networking`.

#### VLANs
You may use VLANs.
* Install the `vlan` package
* Edit `/etc/network/interfaces.d/vlans` with e.g.:
    ```
    auto eth0.10
    iface eth0.10 inet manual
      vlan-raw-device eth0
    ```
* Restart networking, then check with `hostname -I`.
#### Static IP Address
You may want to setup static IPs.
Edit `/etc/dhcpd.conf`:
```
## Untagged interface
interface eth0
static ip_address=<ip>/24
static routers=<router-ip>
static domain_name_servers=<dns-server-ip>
static domain_search=<dns-domain>

## Tagged VLAN interface
interface eth0.10
static ip_address=<ip>/24
static routers=<router-ip>
static domain_name_servers=<dns-server-ip>
static domain_search=<dns-domain>
```
Note: When an option is plural, you can set multiple options,
e.g. for routers, dns, ...

### Firewall
* Install the `ufw` package: `sudo apt install ufw`
* Run the following commands:
    ```bash
    # Basic ufw setup
    sudo ufw allow ssh
    sudo ufw default deny INCOMING
    sudo ufw default allow OUTGOING
    
    # Allow common protocols/applications
    sudo ufw allow Bonjour
    sudo ufw allow 'Nginx HTTPS'
    sudo ufw allow in to any port 60000:60010 proto udp comment 'mosh - mobile shell'
    
    # Allow IGMP
    sudo ufw allow in proto udp to 224.0.0.0/4
    sudo ufw allow in proto udp from 224.0.0.0/4
    ```
* Add to `/etc/ufw/before.rules`:
    ```
    # Allow IGMP
    -A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
    -A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT
    ```
* Please refer to [openHAB](/_openhab/README.md).
* Please refer to [network ups tools](/_docs/NUT.md).
* Enable _ufw_: `sudo ufw enable`

***
## mosh - mobile shell
* Install the `mosh` package: `sudo apt install mosh`

***
## SSH Server

***
## cron-apt

***
## Mail Server
E.g. Postfix

***
## cron

*** 
## Mail on SSH login

***
## Samba
Disable Samba Server: 
```bash
sudo systemctl stop smbd
sudo systemctl disable smbd
```