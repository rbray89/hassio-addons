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
       wget -nv -O- "https://$USERNAME:$PASSWORD@domains.google.com/nic/update?hostname=$DOMAIN&myip=$IP_LATEST" 
    fi
    IP_LAST=$IP_LATEST
    sleep 5s
done
