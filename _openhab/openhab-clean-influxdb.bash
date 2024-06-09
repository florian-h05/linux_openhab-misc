#!/bin/bash
#########################################################################
# Name: openhab-clean-influxdb.bash
# Description: Delete measurements without linked openHAB Items from InfluxDB.
# Author: Florian Hotze
# License: MIT License
#########################################################################

# Prerequisites:
# measurements.txt: Newline separated list of measurements in InfluxDB.
# To create this list, analyze the network requests made by InfluxDB UI's data explorer.

OPENHAB_URL=""
OPENHAB_TOKEN=""

INFLUX_URL=""
INFLUX_TOKEN=""

INFLUX_ORG="openhab"
INFLUX_BUCKET="openhab"

# Time range to delete measurements in
START="2015-01-01T00:00:00.000Z"
STOP=$(date -d "tomorrow" '+%Y-%m-%dT00:00:00.000Z')

# Cleanup
rm items.txt
rm delete.txt

# Get Items from openHAB
curl -X 'GET' \
     -k \
    "$OPENHAB_URL/rest/items?recursive=false&fields=name" \
    -H "accept: application/json" \
    -H "X-OPENHAB-TOKEN: $OPENHAB_TOKEN" | sed 's/,/\n/g' | awk -F '"' '{ print $4}' | sort -n > items.txt

# Calculate measurements to delete
diff -Zu items.txt measurements.txt | grep -i ^+[a-z,0-9] | cut -d '+' -f 2 > delete.txt

# Delete these measurements
LINES=$(cat "delete.txt")

for LINE in $LINES
do
  echo "Deleting measurement $LINE..."
  curl -X 'POST' \
      -k \
      "$INFLUX_URL/api/v2/delete?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET" \
      -H "Content-Type: application/json" \
      -H "Authorization: Token $INFLUX_TOKEN" \
      -d '{ "start": "'$START'", "stop": "'$STOP'", "predicate": "_measurement=\"'$LINE'\"" }'
done

# Cleanup
rm items.txt
rm delete.txt
