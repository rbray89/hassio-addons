#!/bin/bash

CONFIG_PATH=/data/options.json
USE_CONFIG=$(jq --raw-output ".use_cfg" $CONFIG_PATH)

if [[ $USE_CONFIG = false ]]; then

echo "frontend ssl">> /etc/haproxy/haproxy.cfg
echo "mode tcp" >> /etc/haproxy/haproxy.cfg
echo "bind 0.0.0.0:443" >> /etc/haproxy/haproxy.cfg
echo "tcp-request inspect-delay 5s" >> /etc/haproxy/haproxy.cfg
echo "tcp-request content accept if HTTP" >> /etc/haproxy/haproxy.cfg
#echo "# use_backend ssh if { payload(0,7) -m bin 5353482d322e30 }" >> /etc/haproxy/haproxy.cfg
echo "use_backend main-ssl if { req.ssl_hello_type 1 }" >> /etc/haproxy/haproxy.cfg
echo "default_backend openvpn" >> /etc/haproxy/haproxy.cfg

jq --raw-output '.services' $CONFIG_PATH | jq -rc '.[]' | while read SERVICE_CONFIG; do
    TYPE=`echo "$SERVICE_CONFIG" | jq '.type'`
    PORT=`echo "$SERVICE_CONFIG" | jq '.port'`
    PROTOCOL=`echo "$SERVICE_PROTOCOL" | jq '.protocol'`
    echo "backend $TYPE" >> /etc/haproxy/haproxy.cfg
    echo "mode tcp" >> /etc/haproxy/haproxy.cfg
#    echo "timeout server 2h" >> /etc/haproxy/haproxy.cfg
    echo "server $TYPE-localhost 127.0.0.1:$PORT $PROTOCOL" >> /etc/haproxy/haproxy.cfg
done

/usr/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg
else
	/usr/sbin/haproxy -db -f /share/haproxy.cfg
fi

