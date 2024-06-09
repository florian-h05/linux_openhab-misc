#!/bin/bash
#########################################################################
# Name: generate-certs.sh
# Subscription: Generate TLS certs for MQTT broker (Eclipse Mosquitto)
# Author: Florian Hotze
# License: MIT License
#########################################################################

IP="" # Insert your IPv4 address here
HOSTNAME="" # Insert your hostname here

# Set the language
export LANG="de_DE.UTF-8"

SUBJECT_CA="/C=DE/ST=Baden-Wuerttemberg/O=MQTT/CN=MQTT CA"
SUBJECT_SERVER="/C=DE/ST=Baden-Wuerttemberg/O=MQTT/CN=${HOSTNAME}"

# Generate CA
echo "$SUBJECT_CA"
openssl req -x509 -nodes -sha256 -newkey rsa:4096 -subj "$SUBJECT_CA" -days 3650 -keyout ca.key -out ca.crt

# Generate server certificate any key
echo "$SUBJECT_SERVER"
openssl req -nodes -sha256 -newkey rsa:4096 -new -subj "$SUBJECT_SERVER" -addext "subjectAltName=IP:${IP}" -keyout server.key -out server.csr
openssl x509 -req -sha256 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
rm server.csr

# Move certs and server key to config/certs
mv ca.crt config/certs/
mv server.crt config/certs/
mv server.key config/certs/

# Cleanup
rm ca.srl
rm ca.key
