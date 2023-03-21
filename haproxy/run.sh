#!/bin/bash

CONFIG_PATH=/data/options.json
USE_CONFIG=$(jq --raw-output ".use_cfg" $CONFIG_PATH)

if [[ $USE_CONFIG = false ]]; then

mustache-cli $CONFIG_PATH /templates/config.mustache > /etc/haproxy/haproxy.cfg
cat /etc/haproxy/haproxy.cfg

/usr/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg
else
	/usr/sbin/haproxy -db -f /share/haproxy.cfg
fi

