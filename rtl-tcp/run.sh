#!/bin/bash

CONFIG_PATH="/data/options.json"

rtl_tcp_pids=()
for DEVICE in $(jq --raw-output '.devices' $CONFIG_PATH | jq -rc '.[] | @base64'); do
    _jq() {
        echo ${DEVICE} | base64 --decode | jq -r ${1}
    }
    SERIAL=$(_jq '.serial')
    PORT=$(_jq '.port')

    echo "rtl_tcp -a 0.0.0.0 -d $(/rtlsn2dev.sh $SERIAL) -p $PORT"
    rtl_tcp -a 0.0.0.0 -d $(/rtlsn2dev.sh $SERIAL) -p $PORT &
    PID="$!"
    rtl_tcp_pids+=($PID)
done

echo wait -n ${rtl_tcp_pids[@]}
wait -n ${rtl_tcp_pids[@]}
