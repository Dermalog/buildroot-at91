#!/bin/sh

developer_mode=$(fw_printenv | grep -i "developer=" | cut -d= -f2 )

if [ "${developer_mode}" == "1" ]; then
    /sbin/getty -L ttyS0 115200 vt100
else
    sleep 9999999
fi
