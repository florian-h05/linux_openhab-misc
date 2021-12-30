# openHABian setup & changes

This guide describes my personal openHABian setup.

***
## Table of Contents
- [Table of Contents](#table-of-contents)
- [Networking](#networking)
  - [Interface Configuration](#interface-configuration)
    - [VLANs](#vlans)
    - [Static IP Address](#static-ip-address)
  - [Firewall](#firewall)
- [Shell](#shell)
  - [SSH Server](#ssh-server)
  - [mosh - Mobile Shell](#mosh---mobile-shell)
  - [Mail on ssh login](#mail-on-ssh-login)
- [cron-apt](#cron-apt)
- [Mail Server](#mail-server)
- [Samba](#samba)
- [Telegraf](#telegraf)
- [Speedtest CLI](#speedtest-cli)
- [Additional setup](#additional-setup)

***
## Networking

### Interface Configuration

#### VLANs
You may use VLANs.
* Install the `vlan` package
* Edit `/etc/network/interfaces.d/vlans`, add e.g.:
    ```
    auto eth0.10
    iface eth0.10 inet manual
      vlan-raw-device eth0
    ```
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

Restart networking `sudo systemctl restart networking`, then check with `hostname -I`.

### Firewall
* Install the `ufw` package: `sudo apt install ufw`
* Run the following commands:
    ```shell
    # Basic ufw setup
    sudo ufw allow ssh
    sudo ufw default deny INCOMING
    sudo ufw default allow OUTGOING
    
    # Allow common protocols/applications
    sudo ufw allow Bonjour
    sudo ufw allow in to any port 443 proto tcp comment 'HTTPS'
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
## Shell

### SSH Server
Enforce public key authentification & allow local forwarding.
* Paste your public key into `~/.ssh/authorized_keys`.
* Edit `/etc/ssh/sshd_config`:
    * Uncomment the line `PermitRootLogin` and set the value to `no`.
    * Uncomment the line `MaxAuthTries` and set the value to `3`.
    * Uncomment the line `PubkeyAuthentication` and set the value to `yes`.
    * Uncomment the line `PasswordAuthentication` and set the value to `no`.
    * Set the line `UsePAM` to `no`.
    * Uncomment the line `AllowTcpForwarding` and set the value to `local`.
    * Uncomment the line `TCPKeepAlive` and set the value to `no`.
    * Uncomment the line `Compression` and set the value to `no`.
* Restart SSH server `sudo systemctl restart sshd`.

### mosh - Mobile Shell
* Install the `mosh` package: `sudo apt install mosh`

### Mail on ssh login
* Save [sshlogin.bash](/opt/sshlogin.bash) in `/opt`
* Edit `/etc/profile`, add:
    ```shell
    /opt/sshlogin.bash | mailx -s "SSH Login auf Server openHABian-Pi" <your@email.com>
    ```

***
## cron-apt
* Install the `cron-apt` package: `sudo apt install cron-apt`
* Edit `/etc/cron-apt/config`, add:
    ```
    APTCOMMAND=/usr/bin/apt-get
    MAILTO="<your@email.com>"
    MAILON=upgrade
    ```

***
## Mail Server
Use exim4 with GMX (from openHABian config tool).

Only important points are covered:
* `sudo openhabian-config`
* Select `30 | System Settings`.
* Select `3A | Setup Exim Mail Relay`.
* _Mail Server configuration_
    * _General type of mail configuration:_ Select `mail sent by smarthost; no local mail`.
    * _IP address of host name of the outgoing smarthost:_ enter `mail.gmx.net:587`.
* _Enter public mail service smarthost to relay your mails to_: enter `mail.gmx.net`.
* _Enter your public service mail user_: enter your GMX mail address.
* _Enter your public service mail password_: enter your GMX mail password.
* _Enter your administration user's mail address_: enter your GMX mail address.

***
## Samba
Disable Samba Server: 
```shell
sudo systemctl stop smbd
sudo systemctl disable smbd
```

***
## Telegraf
* For installation, visit [influxdata.com](https://portal.influxdata.com/downloads/).
* Use [telegraf.conf](/monitoring/telegraf/telegraf.conf):
    * Set up _hostname_.
    * Set up _[[outputs.influxdb_v2]]_.

***
## Speedtest CLI
* Create folder _speedtest_ and `cd speedtest`.
* Download the latest binary from [speedtest.net](https://www.speedtest.net/apps/cli). For Raspberry Pi you would select _Linux/armhf_. You may use the `wget ${link}` command to download from commandline.
* Untar the _.tgz_: `tar -xzf file.tgz`.
* Copy _speedtest_ to _/usr/bin_: `sudo cp speedtest /usr/bin`.

## Additional setup
* [Network UPS Tools](/_docs/NUT.md)
* [nginx for openHAB](/etc/nginx/sites-enabled/README.md)
* `/etc/fstab` for network mounts
* crontab and root's crontab
* [SBFspot for SMA Inverters](https://github.com/SBFspot/SBFspot/wiki), config file at `/usr/local/bin/sbfspot.3/SBFspot.cfg`