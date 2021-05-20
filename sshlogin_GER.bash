#!/bin/bash

# E-Mail Benachrichtigung bei SSH Login

# Eintrag in /etc/profile benötigt: /opt/sshlogin.sh | mailx -s "SSH login on server <servename>" <email-adress>

if ! command -v nslookup; then sudo apt install dnsutils; fi >/dev/null 2>&1

if ! command -v finger; then sudo apt install finger; fi >/dev/null 2>&1
 
# Hole IP und hostname des Users
ip=$(echo "$SSH_CONNECTION" | cut -d " " -f 1) 
name=$(nslookup "$ip" | grep "name =" | cut -d " " -f 3)
 
# Schreibe in syslog
logger -t ssh-login "$USER" login from "$ip" - "$name"
 
# Ausgabe für eMail
echo "SSH Login auf Server <servername> um $(date +%Y-%m-%d) am $(date +%H:%M)" 
echo 
echo "Benutzer: >$USER< hat sich von IP: >$ip< Hostname: >$name< per SSH angemeldet" 
echo 
finger