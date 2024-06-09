# Setup for my smarthome-related Debian-VM

This guide describes the setup for my openHAB / smarthome VM running on Debian in a VM on a Synology NAS.

## Debian installation

1. Download the latest Debian 11.x version from <https://www.debian.org/download>.
1Use the Graphical installer in the VM.
  1.1. Don't install a desktop environment.
  1.1. Install the ssh server.
  1.1. When the installer asks for a normal user, use `openhabian` as username.
1. Login as root and install the `sudo` package with apt.
1. Add user `openhabian` to `sudo`:
   ```shell
   useradd -aG sudo openhabian
   ```
1. From now on, login as `openhabian`.
1. Install the `qemu-guest-agent` with apt when running in Synology Virtual Machine Manager.
1. Install `git` package with apt.
1. Setup default locale in `/etc/default/locale` (you might need to generate the locale first).

## Networking setup

### Interface Configuration

#### Multiple Network Interafaces

You may use multiple (virtual) NICs.

Get your network configuration with `ip -c addr show`.
Edit `/etc/network/interfaces`, add e.g.:

```
# additional NIC
auto enp0s4
iface enp0s4 inet dhcp
# utoconfigure IPv6
iface enp0s4 inet6 auto
```

#### Static IP Address

You may want to set up static IPs.

Edit `/etc/network/interfaces`, e.g. for `enp04s` change:

```
# Additional NIC
auto enp0s4
iface enp0s4 inet static
  address 192.168.178.2 # own IP
  netmask 255.255.255.0
  gateway 192.168.178.1 # gateway IP
  dns-nameservers 8.8.8.8 192.16.178.1 # DNS server IPs
```

Restart networking with `sudo systemctl restart networking.service`.
Check network configuration with `ip -c addr show`.

### Firewall

* Install the `ufw` package with apt.
* Run the following commands:
    ```shell
    # basic ufw setup
    sudo ufw allow ssh
    sudo ufw default deny INCOMING
    sudo ufw default allow OUTGOING
    
    # allow common protocols/applications
    sudo ufw allow Bonjour
    sudo ufw allow in to any port 443 proto tcp comment 'HTTPS'
    sudo ufw allow in to any port 60000:60010 proto udp comment 'mosh - mobile shell'
    
    # allow IGMP
    sudo ufw allow in proto udp to 224.0.0.0/4
    sudo ufw allow in proto udp from 224.0.0.0/4
    ```
* Add to `/etc/ufw/before.rules` before the `COMMIT` line:
    ```
    # allow IGMP
    -A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
    -A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT
    ```
* Please refer to [openHAB](/_openhab/README.md).
* Please refer to [network ups tools](/_docs/NUT.md).
* Enable _ufw_: `sudo ufw enable`

## Shell setup

### SSH server

Enforce public key authentication & allow local forwarding:

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

* Install `mosh` package with apt.
* Install `tmux` package with apt.

### Mail on ssh login

* Install package `finger` with apt.
* Save [sshlogin.bash](/opt/sshlogin.bash) in `/opt`.
* Make executable: `sudo chmod +X /opt/sshlogin.bash`.
* Edit `/etc/profile`, add:
    ```shell
    /opt/sshlogin.bash | mailx -s "SSH Login auf Server openHABian-Pi" <your@email.com>
    ```

## cron-apt

* Install the `cron-apt` package with apt.
* Edit `/etc/cron-apt/config`, add:
    ```
    APTCOMMAND=/usr/bin/apt-get
    MAILTO="<your@email.com>"
    MAILON=upgrade
    ```

## Mount network drives (Samba/cifs)

* Install the `cifs-utils` package with apt.
* Create a folder as mountpoint, preferably in `/mnt`.
* Add your mount to `/etc/fstab`, e.g.:
  ```
  # network mount
  //192.168.178.2/backup/openHAB /mnt/nas/backup cifs credentials=/home/openhabian/.smb 0 0
  ```
* Add your credentials to `~/.smb`:
  ```
  username=
  password=
  ```
* Mount with `sudo mount /mnt/nas/backup`.

## openHABian installation

Installs openHAB, Frontail (log viewer), Java, FireMotD and exim4 (mail relay server).

Execute the following commands:

```shell
# start shell as root user
sudo bash
then start installation

# install git - you can skip this if it's already installed
apt-get update
apt-get install git

# download, link and create config file
git clone -b openHAB3 https://github.com/openhab/openhabian.git /opt/openhabian
ln -s /opt/openhabian/openhabian-setup.sh /usr/local/bin/openhabian-config
cp /opt/openhabian/build-image/openhabian.conf /etc/openhabian.conf
```

Edit `/etc/openhabian.conf`:

* Set `hostname` to your hostname.
* Comment out: `username`, `userpw`, `adminkeyurl`, `wifi_ssid`, `wifi_password`, `wifi_country`.
* You may import your openHAB backup with the `initialconfig` option.
* Uncomment `hw` and set it to `x86`.
* Uncomment `hwarch` and set it to `amd64`.
* Uncomment `osrelease` and set it to `bullseye`.
* Set `zraminstall` to `disable`.
* Set `hotspot` to `disable`.
* Uncomment the lines under the `# mail relay settings` and set up `adminmail`, `relayuser` and `relaypass`.

Finally, install openHABian with:

```shell
openhabian-config unattended
```

## Samba

Disable Samba Server: 

```shell
sudo systemctl stop smbd
sudo systemctl disable smbd
```

## Trust your own CA

Import the certificate authority on the client:

```
cp <path-to-certfile> /usr/local/share/ca-certificates
sudo update-ca-certificates
```

## NGINX reverse proxy

Follow [NGINX reverse proxy with mTLS auth](https://github.com/florian-h05/linux_openhab-misc/blob/main/etc/nginx/sites-enabled/README.md#client-certificate) to setup client certificate auth for openHAB.

Follow [NGINX systemd unit file](https://github.com/florian-h05/linux_openhab-misc/tree/main/etc/systemd/system#2-nginx) to run NGINX not as root user.

## Speedtest CLI

Execute the following commands:

```
sudo apt-get install curl
curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
sudo apt-get install speedtest
```

## Telegraf

* For installation, visit [influxdata.com](https://portal.influxdata.com/downloads/).
* Use [telegraf.conf](/monitoring/telegraf/telegraf.conf):
    * Set up _hostname_.
    * Set up _[[outputs.influxdb_v2]]_.

## EasyRSA

Follow the [PKI README](../_public-key-infrastucture/README.md) for EasyRSA installation and usage.

## Additional setup

* Network UPS Tools: not required as the Virtual Machine Manager shuts down/halts the VMs when the NAS shuts down.
* crontab and root's crontab
