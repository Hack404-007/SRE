#!/bin/bash
#
DEVICE_NAME=em1
NETWORK=(
    IPADDR=`ip addr | grep ${DEVICE_NAME} | grep  inet | awk '{ print $2; }' | sed 's/\/.*$//'`
    PREFIX=`ip add | grep ${DEVICE_NAME} |egrep "inet|brd" | awk '{print $2}' | awk -F "/" '{print $2}'`
    NETMASK=`ifconfig ${DEVICE_NAME} |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $3}'`
    GATEWAY=172.16.1.1
)
echo ${NETWORK[0]}
echo ${NETWORK[1]}
echo ${NETWORK[2]}
echo ${NETWORK[3]}

