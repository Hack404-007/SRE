#!/bin/bash
#
# Author By: Tommy.Gandolf
# Time: 2016-10-12
# Version: 0.0.1
# Descript: Install KVM Virtual On CenOS 6.x
#IPADDR=`ifconfig ${DEVICE_NAME} |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $2}'`
#HWADDR=`ifconfig ${DEVICE_NAME} |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $1}'`
#NETMASK=`ifconfig ${DEVICE_NAME} |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $3}'`
DEVICE_NAME=em1
KVM_SOFT=(
    kvm python-virtinst libvirt  bridge-utils virt-manager qemu-kvm-tools  virt-viewer  virt-v2v libguestfs-tools tigervnc tigervnc-server
)
NETWORK=(
    IPADDR=`ip addr | grep ${DEVICE_NAME} | grep  inet | awk '{ print $2; }' | sed 's/\/.*$//'`
    PREFIX=`ip add | grep ${DEVICE_NAME} |egrep "inet|brd" | awk '{print $2}' | awk -F "/" '{print $2}'`
    NETMASK=`ifconfig ${DEVICE_NAME} |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $3}'`
    GATEWAY=172.16.1.1
)


INSTALL_FLG()
{
	rpm -qa |grep figlet > /dev/null 2>&1
	if test $? -eq 0; then
        	/usr/bin/figlet -ctf slant "INSTALL KVM"
	else
        	rpm -vih http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm > /dev/null 2>&1
        	yum install figlet -y > /dev/null 2>&1
        	/usr/bin/figlet -ctf slant "INSTALL KVM"
	fi
}

MAKE_DIR()
{
	mkdir -pv /data/{kvm,iso,backup}
	[ -d /data/kvm ] && mkdir -pv /data/kvm/images
	if [ -d /data/kvm -o -d /data/iso -o /data/backup ]; then
		echo "Create Work Dir is Sucessed."
	fi
	
}

BACKUP_IFCFG()
{
	cd  /etc/sysconfig/network-scripts/
	[ -d /data/backup ] || mkdir -pv /data/backup
	if [ ! -e  /data/backup/ifcfg-eth0 ]; then
		cp ifcfg-em*  /data/backup
	fi
}

CHECK_VIR()
{
#Check whether the system supports virtualization
	egrep -E -o  'vmx|svm'  /proc/cpuinfo >>/dev/null
	if [ "$?" -eq "0" ];then
        	echo 'Congratulations, your system success supports virtualization !'
	else
        	echo -e 'OH,your system does not support virtualization !\nPlease modify the BIOS virtualization options (Virtualization Technology)'
        	exit 0
	fi
	if [ -e /usr/bin/virsh ];then
        	echo "Virtualization is already installed ,Please exit ...."
        	exit 0
	fi
}

INSTALL_KVM()
{
	yum -y install ${KVM_SOFT[@]}
	/sbin/modprobe kvm
	/sbin/modprobe kvm_intel
	lsmod | grep kvm >>/dev/null
	if test $? -eq 0; then
        	echo 'KVM installation is successful !'
	else
        	echo 'KVM installation is falis,Please check ......'
        	exit 1
	fi
}



BRIDGE_CFG()
{
	if [ -e /etc/sysconfig/network-scripts/ifcfg-br0 ]; then
    		echo "The ifcfg-br0 already exist ,Please wait exit ......"
    		exit 2
	else
cat >ifcfg-${DEVICE_NAME} <<EOF
DEVICE=${DEVICE_NAME}
BOOTPROTO=none
#${NETWORK[0]}
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE="br0"
#${NETWORK[1]}
#${NETWORK[2]}
#${NETWORK[3]}
USERCTL=no
EOF
cat >ifcfg-br0 <<EOF
DEVICE="br0"
BOOTPROTO=none
${NETWORK[0]}
PV6INIT=no
NM_CONTROLLED=no
ONBOOT=yes
TYPE="Bridge"
${NETWORK[1]}
${NETWORK[2]}
${NETWORK[3]}
USERCTL=no
EOF
	fi
}

#echo ${NETWORK[0]}
#echo ${NETWORK[1]}
#echo ${NETWORK[2]}
#echo ${NETWORK[3]}
#echo ${KVM_SOFT[@]}

# Install Figlet Package 
INSTALL_FLG

# Create Work Directory
MAKE_DIR

# Backup Network Configure File
BACKUP_IFCFG

# Check The Server Is Support Virtualization
CHECK_VIR

# Install KVM  Software Package
INSTALL_KVM

# Configure Bridge For Kvm
BRIDGE_CFG

echo -e "\e[1;32mYou Can Restart Ethernet Service : \n service network restart !\e[0m"
echo
sleep 1
echo -e "\e[1;32mYou Can Restart KVM Service : \n service libvirtd restart !\e[0m"
echo
echo -e "\e[1;32mYou Can Create A KVM Virtual Machine:\e[0m"
cat <<EOF
virt-install  --name=centos6.5 --boot network,cdrom,menu=on --ram 1024 --vcpus=2 --cdrom=/data/ios/CentOS-6.5-x86_64-bin-DVD1.iso  --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel6 --accelerate  --disk path=/data/kvm/images/centos6.qcow2,size=5,format=qcow2,bus=virtio --bridge=br0,model=virtio  --autostart  --virt-type kvm
EOF
