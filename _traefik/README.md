# Traefik as reverse proxy for Docker Containers

## Table of Contents
***
* [Table of Contents](#table-of-contents)
* [1. General information](#1-general-information)
* [2. Preparations](#2-preparations)
* [3. Setup](#3-setup)


## 1. General information
***
[Traefik](https://traefik.io/traefik/) is a "Cloud Native Application Proxy" that perfectly suits for Docker Conatainers. 
This guide will setup Traefik for your Grafana container.

## 2. Preparations
***
Create the Docker network _traefik_: ```sudo docker network create traefik```
Create the files & folders:
  * _acme.json_: ```sudo touch acme.json``` & ```sudo chmod 600 acme.json
  * _conf_: ```sudo
  
Download this directory and place it on your Docker host: 
(do __not forget__ permission settings):
```
main-directory
|-- acme.json         -> /acme.json               | chmod 600
|-- conf              -> /etc/traefik
(|--clientAuth_CA.crt -> /clientCertAuth_CA.crt)
|-- docker-compose.yml
```

## 3. Setup
***
Get a domain from a DynDNS servce provider, for example take a free domain from [DuckDNS](https://duckdns.org).
Setup the DynDNS service in your router or on your server.

Do not forget to open the following ports:
* Outside port ```80``` to ```8080``` of your Docker host.
* Outside port ```443``` to ```8443``` of your Docker host.

Insert your domain name in both files in the [conf folder](./conf).
Insert your domain in the [```docker-compose.yml```](/_openhab/influxdb_grafana/docker-compose.yml) of Grafana.

Finally, run ```sudo docker-compose up -d``` and you should be able to access Grafana on [grafana.my_domain](https://grafana.my_domain).