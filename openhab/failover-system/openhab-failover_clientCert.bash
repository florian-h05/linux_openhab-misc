#!/bin/bash
# Script: openhab-failover_clientCert.bash
# This is the script on the failover host. You must run it regularly, e.g. with crontab or Task Scheduler on Synology NAS.
# Purpose: If openhab not running on main openHAB host, then start Docker container on the failover host.
# How it works: Curl request to openhab, if it fails then start Docker container.
# Author: Florian Hotze

# your openHAB configuration goes here
hostname=""

# your docker container name and notification settings go here
# for notification, this script relies on "signal-cli-rest-api_client.bash", also available at "www.github.com/florian-h05/linux_openhab-misc"
container="openhab_openhab_1"
notify="false"
recipient="" # for notify
path=""
client_certName="user.p12" # client cert has no password!
CA_cert="yourca.crt"

start_docker() {
    if sudo docker start ${container} >/dev/null 2>&1
    then
        CHECK=$(check_container)
        if [ "${CHECK}" == "RUNNING" ]; then echo "SUCCESS: started openhab container."; else echo "FAILED: starting openhab container!" >&2; fi
    else
        echo "FAILED: starting openhab container!" >&2
    fi
}

stop_docker() {
    if sudo docker stop ${container} >/dev/null 2>&1
    then
        CHECK=$(check_container)
        if [ "${CHECK}" == "NOT RUNNING" ]; then echo "SUCCESS: stopped openhab container."; else echo "FAILED: stopping openhab container!" >&2; fi
    else 
        echo "FAILED: stopping openhab container!" >&2
    fi
}

check_container() {
    RUNNING=$(docker inspect --format="{{ .State.Running }}" ${container} 2> /dev/null)
    if [ "${RUNNING}" == "false" ]; then
        echo "NOT RUNNING"
    elif [ "${RUNNING}" == "true" ]; then
        echo "RUNNING"
    fi
}

send_Notification() {
    TEXT="\nPlease check your openHAB installation.\n\nA RUNNING container means that your normal openHAB is not reachable!!\nA NOT RUNNING container menas that your normal openHAB is reachable."
    if [ "${containerStart}" != "${CHECK}" ] && [ "${notify}" == "true" ]
    then
        if bash "${path}"signal-cli-rest-api_client.bash send "${recipient}" "openHAB failover container\n\nThe container's state is: ${CHECK}.${TEXT}" >/dev/null 2>&1; then echo "SUCCESS: sent notifification."; else "ERROR: sending notifiation failed!" >&2; fi
    fi
}

exit_code() {
    if [ "${containerStart}" != "${CHECK}" ]
    then
        exit 1
    fi
}

## when using self-signed certs, you have two options:
#     - use "--cacert" and store your caert in pem format in path
#     - use "--insecure" to ignore self-signed certs
if ! curl -X GET --cert-type P12 --cert "${path}""${client_certName}" https://"${hostname}"/rest/ --cacert "${path}""${CA_cert}" >/dev/null 2>&1
then
    containerStart=$(check_container)
    echo "ERROR: openhab not reachable!" >&2
    start_docker
    send_Notification
    exit_code
else
    containerStart=$(check_container)
    echo "SUCCESS: openhab installation is reachable."
    stop_docker
    send_Notification
fi
