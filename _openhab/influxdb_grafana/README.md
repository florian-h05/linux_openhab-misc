# Persistence and monitoring

## Store and display the history of your openHAB items.
***
## Table of Contents
* [Table of Contents](#table-of-contents)
* [1. Prerequisites](#1-prerequisites)
* [2. Installation](#2-installation)
* [3. InfluxDB](#3-influxdb)
* [4. Grafana](#4-grafana)
* [5. telegraf](#5-telegraf)

***
## 1. Prerequisites
* a Docker host with a 64-bit OS
* a Public Key Infrastucture to create & sign certificates

Create these folders and files on your Docker host/clone them from this repository:
```
main-directory
|-- grafana
|   |-- data          -> /var/lib/grafana
|   |-- grafana.ini   -> /etc/grafana/grafana.ini
|-- influxdb
|   |-- conf          -> /etc/influxdb2
|   |-- data          -> /var/lib/influxdb2
|   |-- ssl_certs     -> /etc/ssl/certs
|-- telegraf
|   |-- telegraf.conf -> /etc/telegraf/telegraf.conf
|-- docker-compose.yml
```

***
## 2. Installation
Go to your _main-directory_, create the docker network ```sudo docker network create traefik``` 
and start everything with ```sudo docker-compose up -d```.

***
## 3. InfluxDB
[InfluxDB](https://www.influxdata.com/products/influxdb/) is a time-series platform

For setup instructions, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/). 

### Use TLS to encrypt your communication
#### InfluxDB's internal TLS
For general TLS setup, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/security/enable-tls/).

For Docker setup, place your certificate and your private key in ```./influxdb``` as cert ```influxdb.crt``` and key ```influxdb.pem```.
Set the permissions:
```shell
sudo chmod 644 ./influxdb/<certificate-file>
sudo chmod 600 ./influxdb/<private-key-file>
```
Have a look at [docker-compose.yml](docker-compose.yml) to enable internal.
Look at the comments and commented out parts.
Go into the terminal of the InfluxDB container and run ```update-ca-certificates```.

#### External Reverse Proxy for TLS
Just leave everything how it is in [docker-compose.yml](docker-compose.yml) and configure your Reverse Proxy for port ```tcp:8087```.

### Setup the clients for TLS
* import the certificate authority on the client:
  ```shell
  cp <path-to-certfile> /usr/local/share/ca-certificates
  sudo update-ca-certificates
  ```
* __IMPORTANT:__ for openHAB, you must import the CA certificate to the JRE:
  ```shell
  # go to the lib/security directory of your JVM, example for openHABian:
  cd /opt/jdk/zulu11.48.21-ca-jdk11.0.11-linux_aarch32hf/lib/security
  # add the certificate to the JAVA keystore
  sudo keytool -importcert -file <path-to-certfile> -cacerts -keypass changeit -storepass changeit -alias <alias-for-cert>
  ```
* configuration in openHAB: ```services/influxdb.cfg```:
  Visit the [official documentation](https://www.openhab.org/addons/persistence/influxdb/), but use:
  ```
  url=https://<influxdb-host>:8086
  ```

***
## 4. Grafana
You can access Grafana on ```http://influxdb-host:3000```.

Add an InfluxDB data source with the following settings:
* _URL_: ```https://influxdb:8086``` -- this uses the internal Docker network
* _Auth_: _Skip TLS Verify_ on

You can also enable remote access to Grafana, please have a look at [Traefik](/_traefik/README.md).

***
## 5. Telegraf
With _Telegraf_ you can monitor your host.

You just have to insert your InfluxDB Token, Bucket and whether to use _http_ or _https_ in the block after that heading:
```conf
###############################################################################
#                            OUTPUT PLUGINS                                   #
###############################################################################
```