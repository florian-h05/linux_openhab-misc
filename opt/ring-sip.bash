#!/bin/bash
# Script: ring-sip.bash
# Purpose: Ring a telephone by using sipcmd VoIP/SIP.
# sipcmd: https://github.com/tmakkonen/sipcmd
# Copyright (C) 2021 Florian Hotze under MIT License

# Prerequisites:
#   add libopal-dev to apt sources for Debian 10/buster
#     add "deb http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi" to /etc/apt/sources.list
#   follow https://github.com/tmakkonen/sipcmd

server="sipserver"
user="username"
password="password"

### default args
number="**600"
ringTime="12s" # approximately: for ringing about 10s use 12s; under 10s use ringing time + 2s
appendText="command line"

### call action
callAction="c${number};ws2000;h"

### Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -n=*|--number=*)
        number="${arg#*=}"
        ;;
        -r=*|--ringtime=*)
        ringTime="${arg#*=}"
        ;;
        -t=*|--text=*)
        appendText="${arg#*=}"
        ;;
        -h|--help)
        echo "Command line args:    
            -n=, --number=    |   number to call
            -r=, --ringtime=  |   limit ring time under 10s, ringing time + 2s
                                    sipcmd limits ring time to 10s
            -t=, --text=      |   text to display on the phone"
        exit 0;;
    esac
  done

# Call: Dial times out after 10s by sipcmd.

timeout "${ringTime}" sipcmd -P sip -u "${user}" -c "${password}" -a "${appendText}" -w "${server}" -x "${callAction}" >/dev/null
