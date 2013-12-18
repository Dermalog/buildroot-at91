#!/bin/sh

BOOTVAR_DEV=/dev/mtd1
ENVVAR_DEV=/dev/mtd2
CMDLINE_FILE=/proc/cmdline
FW_ENV_CONFIG=fw_env.config


sed -e "s|$ENVVAR_DEV|$BOOTVAR_DEV|" -i /etc/fw_env.config # set BOOTVAR for fw_printenv
cmd_nr=$(fw_printenv | sed -n -e 's|^cmd_nr=\(.*\)|\1|p'); 

sed -e "s|$BOOTVAR_DEV|$ENVVAR_DEV|" -i /etc/fw_env.config # set ENVVAR for fw_printenv
varcmdline="$(fw_printenv | grep cmd$cmd_nr )" ; varcmdline=${varcmdline:5};

cmdline=$(cat $CMDLINE_FILE)

echo "cmd_nr=$cmd_nr"
echo "varcmdline=$varcmdline"
echo "cmdline=$cmdline"

if [[ "$cmdline" != "$varcmdline" ]] ; then 
    echo "First boot after update"
    cmd_nr=$(( $((cmd_nr + 1)) % 2 ))
    varcmdline="$(fw_printenv | grep cmd$cmd_nr )" ; varcmdline=${varcmdline:5};
    if [[ "$cmdline" != "$varcmdline" ]] ; then 
	echo "ERROR: other command line also not equal to the current one"
	exit -1
    fi
    echo "Change default boot cmdline to the current(cmd_nr=$cmd_nr)"
    sed -e "s|$ENVVAR_DEV|$BOOTVAR_DEV|" -i /etc/fw_env.config # set BOOTVAR for fw_printenv
    fw_setenv cmd_nr $cmd_nr
fi

