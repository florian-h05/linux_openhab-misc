#!/bin/bash
# Script: openhab-to-failover-host.bash
# This is the script on the main openHAB host. You should run it regularly, e.g. with crontab.
# Purpose: Copy openhab configuration to the failover host.
# Author: Florian Hotze

mountPath=""
knx="false" # if you are using knx, set to true -- it expects /things/knx.things
knxIP='"<ip-address>"'
failoverHost='"<ip-address>"'

declare -A path
path=([/var/lib/openhab]="userdata" [/etc/openhab]="conf")

## copy_file "path-of-file" "filename"
copy_file() {
    if [ -f "${mountPath}"/"${path[${1}]}"/"${2}" ]; then
        sudo rm "${mountPath}"/"${path[${1}]}"/"${2}"
    fi
    sudo mkdir -p "${mountPath}"/"${path[${1}]}"
    if sudo cp -R "${1}"/"${2}" "${mountPath}"/"${path[${1}]}"; then echo "SUCCESS: copied ${1}/${2}"; else echo "ERROR: failed to copy ${1}/${2}"; fi
}

## copy_file "path-of-folder" "foldername"
copy_folder() {
    if [ -d "${mountPath}"/"${path[${1}]}"/"${2}" ]; then
        sudo rm -R "${mountPath}"/"${path[${1}]}"/"${2}"
    fi
    sudo mkdir -p "${mountPath}"/"${path[${1}]}"
    if sudo cp -R "${1}"/"${2}" "${mountPath}"/"${path[${1}]}"; then echo "SUCCESS: copied ${1}/${2}"; else echo "ERROR: failed to copy ${1}/${2}"; fi
}

## copy_file "directory" "*"
copy_directoryContent() {
    if [ -d "${mountPath}"/"${path[${1}]}" ]; then
        sudo rm -R "${mountPath}"/"${path[${1}]}"
    fi
    sudo mkdir -p "${mountPath}"/"${path[${1}]}"
    if sudo cp -R "${1}"/* "${mountPath}"/"${path[${1}]}"; then echo "SUCCESS: copied ${1}/${2}"; else echo "ERROR: failed to copy ${1}/${2}"; fi
}

knx_replace() {
    if [ "${knx}" == "true" ]
    then
        echo "Configuring knx.things for Docker ...."
        SEARCH='type="ROUTER"' REPLACE='type="TUNNEL"'
        sudo sed -i 's/'"${SEARCH}"'/'"${REPLACE}"'/' "${mountPath}"/conf/things/knx.things
        SEARCH='ipAddress=""' REPLACE='ipAddress='"${knxIP}"''
        sudo sed -i 's/'"${SEARCH}"'/'"${REPLACE}"'/' "${mountPath}"/conf/things/knx.things
        SEARCH='localIp=""' REPLACE='localIp='"${failoverHost}"''
        sudo sed -i 's/'"${SEARCH}"'/'"${REPLACE}"'/' "${mountPath}"/conf/things/knx.things
    fi
}

# copy conf
copy_directoryContent "/etc/openhab" "*"
if [ -f "${mountPath}"/conf/things/knx.things ]
then
    if knx_replace; then echo "SUCCESS: configured knx.things for Docker."; else echo "ERROR: configuring knx.things for Docker failed!"; fi
fi

# copy userdata
## openhabcloud and uuid only for the first time!
#copy_file "/var/lib/openhab" "openhabcloud"
#copy_file "/var/lib/openhab" "uuid"
copy_folder "/var/lib/openhab" "persistence"