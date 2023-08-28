#!/bin/bash
# usage: ./rtlsn2dev.sh [serial number]
# returns: device ID
if [ $1 ]
then
  rtl_tcp -d 9999 |& sed -E -n "s/([0-9]+):\s*.+SN: $1/\1/p"
fi