#!/bin/bash


HOSTIP=`ifconfig |grep "10.10"|awk -F: '{print $2}' |awk '{ print $1}'`

if_eth0='/etc/sysconfig/network-scripts/ifcfg-eth0'
#if_eth0='/root/ifcfg-eth0'
if_eth1='/etc/sysconfig/network-scripts/ifcfg-eth1'
#if_eth1='/root/ifcfg-eth1'
cat > ${if_eth0} << EOF
DEVICE=eth0
BOOTPROTO=static
ONBOOT=no
EOF

cat > ${if_eth1} << EOF
DEVICE=eth1
BOOTPROTO=static
ONBOOT=yes
IPADDR=${HOSTIP}
NETMASK=255.255.254.0
GATEWAY=10.10.206.14
DNS1=114.114.114.114
DNS2=8.8.8.8
EOF
