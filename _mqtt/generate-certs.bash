#!/usr/bin/env bash
#########################################################################
# Name: generate-certs.sh
# Description: Generate TLS certs for MQTT broker (Eclipse Mosquitto)
# Author: Florian Hotze
# License: MIT License
#########################################################################
# Set the language
export LANG="de_DE.UTF-8"
# Load the Paths
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Change to your needs
IP="xxx.xxx.xxx.xxx"
HOSTNAME=""
SUBJECT_CA="/C=DE/ST=Baden-Wuerttemberg/O=MQTT/CN=MQTT CA"
SUBJECT_SERVER="/C=DE/ST=Baden-Wuerttemberg/O=MQTT/CN=${HOSTNAME}"

function generate_CA () {
   echo "$SUBJECT_CA"
   openssl req -x509 -nodes -sha256 -newkey rsa:4096 -subj "$SUBJECT_CA" -days 3650 -keyout ca.key -out ca.crt
}

function generate_server () {
   echo "$SUBJECT_SERVER"
   openssl req -nodes -sha256 -newkey rsa:4096 -new -subj "$SUBJECT_SERVER" -addext "subjectAltName=IP:${IP}" -keyout server.key -out server.csr
   openssl x509 -req -sha256 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
}

function copy_to_mosquitto () {
   cp ca.crt ../config/certs/
   cp server.crt ../config/certs/
   cp server.key ../config/certs/
}

generate_CA
generate_server
copy_to_mosquitto
