#!/bin/sh

/bin/mkdir -p /tmp/etc
serial=$(fw_printenv | grep serial= | cut -d= -f2 |tr ' ' '_') ; echo "${serial}" >/tmp/etc/hostname
mkdir -p /tmp/etc/samba
echo "workgroup = WORKGROUP" > /tmp/etc/samba/smb.conf
echo "netbios name = ${serial}" >> /tmp/etc/samba/smb.conf

ipcfg=$(fw_printenv | grep ip= | cut -d= -f2) 

mkdir -p /tmp/etc/network
cat <<EOF >/tmp/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
EOF

if [ "${ipcfg}" == "" ]; then
    ipcfg="dhcp"
fi

if [ "${ipcfg}" == "dhcp" ]; then
    echo "iface eth0 inet dhcp"   >> /tmp/etc/network/interfaces 
else
    ip=$(echo "${ipcfg}" | cut -d ' ' -f1 )
    nm=$(echo "${ipcfg}" | cut -d ' ' -f2 )
    gw=$(echo "${ipcfg}" | cut -d ' ' -f3 )
    echo "iface eth0 inet static" >> /tmp/etc/network/interfaces
    echo "    address ${ip}"      >> /tmp/etc/network/interfaces
    echo "    netmask ${nm}"      >> /tmp/etc/network/interfaces
    echo "    gateway ${gw}"      >> /tmp/etc/network/interfaces
fi




