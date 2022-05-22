#!/usr/bin/env bash
#########################################################################
# Name: generate-certs.sh
# Description: Generate TLS certs for MQTT broker (Eclipse Mosquitto)
# Note: Run this script from your Docker Compose project root!
# Author: Florian Hotze
# License: MIT License
#########################################################################
# Set the language
export LANG="de_DE.UTF-8"
# Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Change to your needs
IP="IP or FQDN"
SUBJECT_CA="/C=DE/ST=Baden-Wuerttemberg/L=/O=MQTT/OU=CA/CN=$IP"
SUBJECT_SERVER="/C=DE/ST=Baden-Wuerttemberg/L=/O=MQTT/OU=Server/CN=$IP"

function create_directories () {
   mkdir -p ./certs
   mkdir -p ./config/certs
}

function generate_CA () {
   echo "$SUBJECT_CA"
   openssl req -x509 -nodes -sha256 -newkey rsa:4096 -subj "$SUBJECT_CA" -days 3650 -keyout ./certs/ca.key -out ./certs/ca.crt
}

function generate_server () {
   echo "$SUBJECT_SERVER"
   openssl req -nodes -sha256 -newkey rsa:4096 -new -subj "$SUBJECT_SERVER" -keyout ./certs/server.key -out ./certs/server.csr
   openssl x509 -req -sha256 -in ./certs/server.csr -CA ./certs/ca.crt -CAkey ./certs/ca.key -CAcreateserial -out ./certs/server.crt -days 3650
}

function copy_to_mosquitto () {
   cp ./certs/ca.crt ./config/certs/
   cp ./certs/server.crt ./config/certs/
   cp ./certs/server.key ./config/certs/
}

create_directories
generate_CA
generate_server
copy_to_mosquitto
