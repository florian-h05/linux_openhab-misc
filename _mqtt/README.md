# MQTT Broker in Docker (Eclipse Mosquitto)

## Preparations

- Create the following folders:
  ```shell
  mkdir config
  mkdir data
  mkdir certs
  ```
- Place [docker-compose.yml](docker-compose.yml) in your project's root.
- Place [generate-certs.bash](generate-certs.bash) in your project's root.
- Place [mosquitto.conf](config/mosquitto.conf) in `config`.
- Create `mosquitto.passwd` in `config`: `touch config/mosquitto.passwd`.

## Generate required certs

- Place [`generate-certs.bash`](generate-certs.bash) in the `certs` folder.
- Edit [`generate-certs.bash`](generate-certs.bash) and set up your IP and your subjects.
- Make the script executable with `chmod +x generate-certs.bash`
- Run with `bash generate-certs.bash`.

This will create all required certs and copy them to the right locations.

## Create container

Run `sudo docker-compose up -d`.

## Setup users

To create the first user, run from your compose project root:

```shell
docker-compose exec mosquitto mosquitto_passwd -c /mosquitto/config/mosquitto.passwd username
```

To add more users, run from your compose project root:

```shell
docker-compose exec mosquitto mosquitto_passwd /mosquitto/config/mosquitto.passwd username
```

See [mosquitto_passwd man page](https://mosquitto.org/man/mosquitto_passwd-1.html) for more information.

## Test your broker
You can use [MQTT Explorer](http://mqtt-explorer.com/) to graphically explore from your desktop.
You can use [MQTTAnalyzer](https://apps.apple.com/de/app/mqttanalyzer/id1493015317) to graphically explore from your iOS device.
