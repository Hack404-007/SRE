#!/bin/bash
# author: Tommy
# date: 2017.07.06
# modify netmask and add route

inter_Dir='/etc/sysconfig/network-scripts'
inter_Eth='ifcfg-eth1'
inter_Em='ifcfg-em2'

interface=$(dmesg  | grep "renamed network" | awk '{print $7":"$5}'|head -1)

add_route()
{
rm -f /etc/sysconfig/static-routes
wget -q -O  /etc/sysconfig/static-routes http://113.31.16.198:8889/init_machine/static-routes-BJYZ
if test $? -eq 0; then
	echo -e "\e[1;32m add static-routes file sucessed and restart network..\e[0m"
	sleep 3
	echo -e "\e[1;32m Do you want to Restart network service..[y|Y|yes|n|N|no|NO]\e[0m"
        read choice
	case "${choice}" in
		y|Y|yes|YES)
		/etc/init.d/network  restart
		;;
		n|N|no|NO)
		exit 0
		;;
		*)
		echo "Exit ...."
		exit 0
	esac
else
        echo -e  "\e[1;32m add static-routes file false..\e[0m"
        exit 0
fi

}       


if [ -n "${interface}" ]; then
	echo "Em2 Interface is Exist.."
	echo -e "\e[1;32m 开始修改子网掩码..\e[0m"
	sed -i 's@\(NETMASK=\).*@\1255.255.254.0@g' ${inter_Dir}/${inter_Em}
	if test $? -eq 0; then
		echo -e "\e[1;32m Modify ${inter_Em} sucessed..\e[0m"
		sleep 2
	fi
	
else
	echo "Eth Interface is Exist.."
	echo -e "\e[1;32m 开始修改子网掩码..\e[0m"
	sed -i 's@\(NETMASK=\).*@\1255.255.254.0@g' ${inter_Dir}/${inter_Eth}
	if test $? -eq 0; then
		echo -e "\e[1;32m Modify ${inter_Eth} sucessed..\e[0m"
		sleep 2
	fi
fi

add_route
