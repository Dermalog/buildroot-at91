#!/bin/sh

cidr2mask() {
  local i mask=""
  local full_octets=$(($1/8))
  local partial_octet=$(($1%8))

  for i in $(seq 0 3); do
    if [ $i -lt $full_octets ]; then
      mask=${mask}255
    elif [ $i -eq $full_octets ]; then
      mask=${mask}$((256 - 2**(8-$partial_octet)))
    else
      mask=${mask}0
    fi
    test $i -lt 3 && mask=${mask}.
  done

  echo $mask
}

ipnm2bc() {
    local ipl=${1}
    local nml=${2}
    local ipl0=$(echo $ipl | cut -d . -f1)
    local ipl1=$(echo $ipl | cut -d . -f2)
    local ipl2=$(echo $ipl | cut -d . -f3)
    local ipl3=$(echo $ipl | cut -d . -f4)
    local nml0=$(echo $nml | cut -d . -f1)
    local nml1=$(echo $nml | cut -d . -f2)
    local nml2=$(echo $nml | cut -d . -f3)
    local nml3=$(echo $nml | cut -d . -f4)
    local bcl0=""
    local bcl1=""
    local bcl2=""
    local bcl3=""

    bcl0=$(( ( ${ipl0} & ${nml0} ) |  ( ${nml0} ^ 255 ) ));
    bcl1=$(( ( ${ipl1} & ${nml1} ) |  ( ${nml1} ^ 255 ) ));
    bcl2=$(( ( ${ipl2} & ${nml2} ) |  ( ${nml2} ^ 255 ) ));
    bcl3=$(( ( ${ipl3} & ${nml3} ) |  ( ${nml3} ^ 255 ) ));
    echo "${bcl0}.${bcl1}.${bcl2}.${bcl3}"
}


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
    ip_input=$(echo "$ipcfg"  | cut -d ' ' -f1)
    gw=$(echo "${ipcfg}"      | cut -d ' ' -f2)
    ip=$(echo "${ip_input}"   | cut -d '/' -f1)
    cidr=$(echo "${ip_input}" | cut -d '/' -f2)
    nm=$(cidr2mask $cidr)
    bc=$(ipnm2bc ${ip} ${nm})
    echo "iface eth0 inet static" >> /tmp/etc/network/interfaces
    echo "    address   ${ip}"    >> /tmp/etc/network/interfaces
    echo "    netmask   ${nm}"    >> /tmp/etc/network/interfaces
    echo "    broadcast ${bc}"    >> /tmp/etc/network/interfaces
    echo "    gateway   ${gw}"    >> /tmp/etc/network/interfaces
fi

developer_mode=$(fw_printenv | grep -i "developer=" | cut -d= -f2 )

if [ "${developer_mode}" == "1" ]; then 
    echo "DEVELOPER MODE"
    mount -o rw,remount /    
    echo "root:b9QQzXd6xCK8I:0:0:root:/root:/bin/sh" >/tmp/etc/passwd
    echo "sshd:x:103:99:Operator:/var:/bin/sh" >>/tmp/etc/passwd
else
    echo "root:x:0:0:root:/root:/bin/false" >/tmp/etc/passwd
fi


