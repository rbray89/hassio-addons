#!/bin/bash
# usage: ./rtlsn2dev.sh [serial number]
# returns: device ID
if [ $1 ]
then
  rtl_num_devices=$(rtl_eeprom 2>&1 >/dev/null | grep "Found [0-9][0-9]*" | sed -E 's/.*([0-9]+).*/\1/')
  if [ $rtl_num_devices ]
  then
    for i in $(seq 1 $rtl_num_devices);
    do
      rtl_device=$((i-1))
      rtl_serial=$(rtl_eeprom -d$rtl_device 2>&1 >/dev/null | grep "Serial number\:" | sed -E 's/Serial number:[[:blank:]]+//')
      if [ "$1" == "$rtl_serial" ]
      then
        echo $rtl_device
      fi
    done
  fi
fi