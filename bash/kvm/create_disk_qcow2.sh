#!/bin/bash
#
# Author By: Tommy.Gandolf
# Time: 2016-10-12
# Version: 0.0.1
# Descript: Create  KVM Virtual Disk For qcow2 Fromat

KVM_IMAGE=/data/kvm/images
KVM_ISO=/data/iso
KVM_VM_IMAGE_NAME=CENTOS_VM
KVM_DISK_SIZE=200G
QEMU_EXEC=/usr/bin/qemu-img

[ -d ${KVM_IMAGE} ] || mkdir -pv ${KVM_IMAGE} && echo  -e "\e[1;32mCreate KVM Images Directory Sucessed.\e[0m"
[ -d ${KVM_ISO} ] || mkdir -pv ${KVM_ISO} && echo -e "\e[1;32mCreare KVM ISO Directory Sucessed.\e[0m"
echo 

for i in {1..4}; do
	${QEMU_EXEC} create -f qcow2 -o size=${KVM_DISK_SIZE},preallocation="metadata" ${KVM_IMAGE}/${KVM_VM_IMAGE_NAME}_${i}.qcow2 > /dev/null 2>&1
	if test $? -eq 0; then
		echo -e  "\e[1;32mCreate KVM Disk ${KVM_VM_IMAGE_NAME}_${i} Sucessed.\e[0m"
	else
		echo -e  "\033[31mCreate KVM Disk ${KVM_VM_IMAGE_NAME}_${i} Failed.\033[0m"
	fi
done
