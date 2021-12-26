#!/bin/bash

# Mail notification on SSH login

# entry in /etc/profile needed: /opt/sshlogin.sh | mailx -s "SSH login on server <servename>" <email-adress>

if ! command -v nslookup; then sudo apt install dnsutils; fi >/dev/null 2>&1

if ! command -v finger; then sudo apt install finger; fi >/dev/null 2>&1

# get IP and hostname of user who logged in
ip=$(echo "$SSH_CONNECTION" | cut -d " " -f 1) 
name=$(nslookup "$ip" | grep "name =" | cut -d " " -f 3)
 
# write to syslog
logger -t ssh-login "$USER" login from "$ip" - "$name"
 
# output for e-mail
echo "SSH login on Server <servername> at $(date +%Y-%m-%d) at $(date +%H:%M)" 
echo 
echo "user: >$USER< logged in from IP: >$ip< Hostname: >$name< over SSH" 
echo 
finger
