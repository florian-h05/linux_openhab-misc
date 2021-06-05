# Script: openhab-log-influx.py
# Purpose: write log messages to InfluxDB and append weather data from openHAB
# Auhor: Florian Hotze
#
## this script is using InfluxDB v2's FLUX language instead of the InfluxQL by influxdb_client Python Library
## this script is using OpenHAB Python Library
##
## install depedencies with:
##  - "sudo -H python3 -m pip install influxdb_client"
##  - "sudo -h python3 -m pip install python-openhab"

import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

from openhab import OpenHAB

import argparse
 
# Initialize parser
parser = argparse.ArgumentParser()
# Adding optional argument
parser.add_argument("-t", "--Type", help = "Set type of log, e.g. knx or openhab")
parser.add_argument("-l", "--Log", help = "Log message, e.g. 'test log'")
parser.add_argument("-d", "--Device", help = "Device of the log, e.g. 'system-wide' or 'Florian_Rolladen'")
# Read arguments from command line
args = parser.parse_args()


# Initialize openHAB client
base_url="http://localhost:8080/rest"
openhab = OpenHAB(base_url)
items = openhab.fetch_all_items()

# Initialize InfluxDB client
bucket = "openhab"
org = "openhab"
token = 'influxdb-token'
# Store the URL of your InfluxDB instance
url="http://localhost:8086"

loggername = "smarthome-log"


# Read arguments from command line
args = parser.parse_args()

type = args.Type
log = args.Log
device = args.Device

# Data to append to the log
temp = float(items.get('Aussentemperatur').state)
wind = float(items.get('Windgeschwindigkeit').state)
brightness = float(items.get('Helligkeit').state)
rain = str(items.get('RegenalarmStr').state)
elevation = float(items.get('Elevation').state)
azimuth = float(items.get('Azimut').state)

client = influxdb_client.InfluxDBClient(
    url=url,
    token=token,
    org=org
)

write_api = client.write_api(write_options=SYNCHRONOUS)

p = influxdb_client.Point(loggername).tag("type", type).tag("device", device).field("log", log).field("device", device).field("temperature", temp).field("windspeed", wind).field("brightness", brightness).field("rain", rain).field("elevation", elevation).field("azimuth", azimuth)
write_api.write(bucket=bucket, org=org, record=p)
