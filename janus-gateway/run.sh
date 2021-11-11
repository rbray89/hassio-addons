#!/bin/bash

CONFIG_PATH=/data/options.json
USE_CONFIG=$(jq --raw-output ".use_cfg" $CONFIG_PATH)
API_SECRET=$(jq --raw-output ".api_secret" $CONFIG_PATH) 

if [[ $USE_CONFIG = false ]]; then
echo '' > /usr/local/etc/janus/janus.plugin.streaming.jcfg
cat $CONFIG_PATH 
jq --raw-output '.streams' $CONFIG_PATH | jq -rc '.[]' | while read STREAM_CONFIG; do
    NAME=`echo "$STREAM_CONFIG" | jq '.name' | tr -d '"'`
    echo "$NAME: {" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    echo "description =  \"RTSP $NAME Stream\"" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    TYPE=`echo "$STREAM_CONFIG" | jq '.type'`
    echo "type = $TYPE" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    AUDIO=`echo "$STREAM_CONFIG" | jq '.audio'`
    echo "audio = $AUDIO" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    VIDEO=`echo "$STREAM_CONFIG" | jq '.video'`
    echo "video = $VIDEO" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    URL=`echo "$STREAM_CONFIG" | jq '.url'`
    echo "url = $URL" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    RTSP_USER=`echo "$STREAM_CONFIG" | jq '.rtsp_user'`
    echo "rtsp_user = $RTSP_USER" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    RTSP_PWD=`echo "$STREAM_CONFIG" | jq '.rtsp_pwd'`
    echo "rtsp_pwd = $RTSP_PWD" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
    echo "}" >> /usr/local/etc/janus/janus.plugin.streaming.jcfg
done

else
  cp /share/janus/*.jcfg /usr/local/etc/janus/
fi

sed -i "s/@API_SECRET@/$API_SECRET/g" /usr/local/etc/janus/janus.jcfg

/usr/local/bin/janus -o
