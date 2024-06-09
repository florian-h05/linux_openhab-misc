# Persistence and Monitoring

Store and display the history of your openHAB Items & monitor your openHAB runtime and host.

## Prerequisites

* Docker host with a 64-bit OS
* Public Key Infrastructure to create & sign certificates

Create these folders and files on your Docker host/clone them from this repository:
```
monitoring
|-- grafana
|   |-- data          -> /var/lib/grafana
|   |-- grafana.ini   -> /etc/grafana/grafana.ini
|-- influxdb
|   |-- conf          -> /etc/influxdb2
|   |-- data          -> /var/lib/influxdb2
|   |-- ssl_certs     -> /etc/ssl/certs
|-- prometheus        -> /etc/prometheus
|   |-- .password
|   |-- prometheus.yml
|   |-- ca.crt
|-- telegraf
|   |-- telegraf.conf -> /etc/telegraf/telegraf.conf
|-- docker-compose.yml
```

## Installation

Go to your _monitoring_ directory, create the docker network `sudo docker network create traefik` and start everything with `sudo docker-compose up -d`.

## InfluxDB

[InfluxDB](https://www.influxdata.com/products/influxdb/) is a time-series database.

Installed by `docker-compose`.
For setup instructions, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/). 

### InfluxDB's internal TLS

For general TLS setup, please visit the [official documentation](https://docs.influxdata.com/influxdb/v2.0/security/enable-tls/).

Place your certificate `influxdb.crt` and your private key `influxdb.pem` in `./influxdb` .

Set the permissions:

```shell
sudo chmod 644 ./influxdb/<certificate-file>
sudo chmod 600 ./influxdb/<private-key-file>
```

In [docker-compose.yml](docker-compose.yml) comment out the sections with comment `Internal TLS`.

Go into the terminal of the InfluxDB container and run `update-ca-certificates`.

### External Reverse Proxy for TLS

Just leave everything how it is in [docker-compose.yml](docker-compose.yml) and configure your Reverse Proxy for port `tcp:8087`.

### Setup clients to use TLS

Import the certificate authority on the client:

```shell
cp <path-to-certfile> /usr/local/share/ca-certificates
sudo update-ca-certificates
```

## Prometheus

[Prometheus](https://prometheus.io/) fetches the runtime metrics from openHAB and makes them accessible for Grafana.

Installed by `docker-compose`.

### Prerequisites

* Add the user `prometheus` to your openHAB reverse proxy's basic auth users.
  * Create a file called `.password` at `$docker_host/monitoring/prometheus` with the basic auth password in it.
* In `$docker_host/monitoring/prometheus/prometheus.yml`:
  * Set `${HOSTNAME}` to your hostname.
  * In `scrape_configs`/`job_name: 'openhab'`:
    * Set up the scheme of the scrape_config: `http` or `https`.
      * When using http, you do not need the `tls_config` section, comment it out.
    * Setup the target to the address and port of your openHAB.

## openHAB

### Setup InfluxDB

* Import the CA certificate to the JRE:
  ```shell
  # go to the lib/security directory of your JVM, example for openHABian:
  cd /opt/jdk/zulu11.48.21-ca-jdk11.0.11-linux_aarch32hf/lib/security

  # add the certificate to the JAVA keystore
  sudo keytool -importcert -file <path-to-certfile> -cacerts -keypass changeit -storepass changeit -alias <alias-for-cert>
  ```
* Install the `InfluxDB Persistence` Add-On.
* Configure InfluxDB: [Read the documentation](https://www.openhab.org/addons/persistence/influxdb/).

### Setup runtime monitoring (Prometheus)

* Install the `Metrics Service` Add-On.

## Grafana

You can access Grafana on `http://<docker-host>:3000`.

You can also enable remote access to Grafana, please have a look at [SWAG](/_swag/README.md).

### InfluxDB 

Add an InfluxDB data source with the following settings:

* _Query Language_: Select the language you want to use, for `InfluxQL` you have to [use v1 users](https://docs.influxdata.com/influxdb/v2.1/reference/cli/influx/v1/auth/).
* _URL_: `http://influxdb:8086` -- internal Docker networking
* _Auth_
  * _Skip TLS Verify_: on
* _InfluxDB Details_

### Prometheus

Add a Prometheus data source with the following settings:

* _URL_: `http://prometheus:9090` -- internal Docker networking
* No further configuratio needed.
* Import the dashboard from [openHAB System Integrations Metrics service](https://github.com/openhab/openhab-addons/blob/main/bundles/org.openhab.io.metrics/doc/dashboard.json).

## Telegraf

With _Telegraf_ you can monitor your host.

You just have to insert your InfluxDB Token, Bucket and whether to use _http_ or _https_ in the block after that heading:
```conf
###############################################################################
#                            OUTPUT PLUGINS                                   #
###############################################################################
```
