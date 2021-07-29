# Persistence and monitoring

## Store and display the history of your openHAB items.
***
## Table of Contents
1. [Requirements](#requirements)
2. [file tree](#file-tree)
3. [InfluxDB](#influxdb)
4. [Grafana](#grafana)

***
## Requirements:
* a Docker host with a 64-bit OS
* a Public Key Infrastucture to create & sign certificates

*** 
## file tree
Create these folders on your Docker host:
```
main-directory
|-- influxdb
|   |-- data          -> /var/lib/influxdb2
|   |-- etc           -> /etc/influxdb2
|      (|-- ssl       for certificate and private key; only create after the first start of InfluxDB)
|-- grafana
|   |-- data          -> /var/lib/grafana
|   |-- grafana.ini   -> /etc/grafana/grafana.ini
|-- docker-compose.yml
```

***
## Installation
Go to your _main-directory_ and execute: ```sudo docker-compose up -d```

***
## InfluxDB
[InfluxDB](https://www.influxdata.com/products/influxdb/) is a time-series platform

For setup instructions, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/). 

### Use TLS to encrypt your communication
For general TLS setup, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/security/enable-tls/).

For Docker setup, place your certificate and your private key in ```./influxdb/etc/ssl``` as cert ```influxdb.crt``` and key ```inflxdb.pem```.
Set the permissions:
```shell
sudo chmod 644 ./influxdb/etc/ssl/<certificate-file>
sudo chmod 600 ./influxdb/etc/ssl/<private-key-file>
```
Uncomment out lines 14-16 in [docker-compose.yml](docker-compose.yml) to enable TLS:
```yml
....
    environment:
      - INFLUXD_TLS_CERT=/etc/influxdb2/ssl/influxdb.crt
      - INFLUXD_TLS_KEY=/etc/influxdb2/ssl/influxdb.pem
....    
```

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
## Grafana
You can access Grafana on ```http://influxdb-host:3001```.

Add an InfluxDB data source with the following settings:
* _URL_: ```https://influxdb:8086``` -- this uses the internal Docker network
* _Auth_: _Skip TLS Verify_ on
* Setup _the InfluxDB Details_