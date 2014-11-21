#!/bin/sh
REMOTEIP=10.0.0.1
LOCALIP=10.0.0.2
PPPDEV=/dev/ppp
TTYDEV=/dev/ttyGS0
GADGET_SERIAL=1

if [ ! -c ${TTYDEV} ]; then
    if [ ${GADGET_SERIAL} ]; then
        modprobe ppp_generic
        if [ $? != 0 ]; then
            echo "failed to load ppp_generic"
            exit 1
        fi
    else
        echo "failed to find tty device ${TTYDEV}"
        exit 2
    fi
fi

if [ ! -c ${PPPDEV} ]; then
    mknod ${PPPDEV} 108 0
    if [ $? != 0 ]; then
        echo "failed to create character device node ${PPPDEV}"
        exit 3
    fi
fi

pppd -detach crtscts lock ${LOCALIP}:${REMOTEIP} ${TTYDEV} 115200 

