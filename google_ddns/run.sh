#!/bin/bash

CONFIG_PATH=/data/options.json

USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password" $CONFIG_PATH)
DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)
IPFLTR=$(jq --raw-output ".ipfltr" $CONFIG_PATH)
IP_LAST=""

while true; do
    IP_LATEST=$(eval $IPFLTR)
    if [ "$IP_LATEST" != "$IP_LAST" ]; then
       echo "IP CHANGED: $IP_LATEST"
       wget "https://$USERNAME:$PASSWORD@domains.google.com/nic/update?hostname=$DOMAIN&myip=$IP_LATEST" -nv -O- 
    fi
    IP_LAST=$IP_LATEST
    sleep 5s
done
