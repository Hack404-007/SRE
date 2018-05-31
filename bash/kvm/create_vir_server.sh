#!/bin/bash
#
# Author By: Tommy.Gandolf
# Time: 2016-10-13
# Version: 0.0.2
# Descript: Create KVM Virtual Server

KVM_ISO_DIR=/data/iso/CentOS-6.5-x86_64-bin-DVD1.iso
KVM_BOOT_NET=http://xxxxxx
KVM_IMAGE_DIR=/data/kvm/images
VIRT_EXEC=/usr/sbin/virt-install
VIRT_RAM=4096
VIRT_CPU=4
KVM_DISK=$(lvdisplay | grep "LV Path" | awk '{print $NF}')

/etc/init.d/libvirtd  status > /dev/null
if [ !  $? -eq 0 ]; then
	/etc/init.d/libvirtd start
else
	/etc/init.d/libvirtd restart
fi

if [ ! -f ${KVM_ISO_DIR} ]; then
	echo -e "\033[31mThe Server Not Found ISO File.\033[0m"
	echo -e "\e[1;32mPlease Upload System ISO File To the Server.\e[0m"
	exit 0
fi

for disk in ${KVM_DISK}; do
	VIR_NAME=`echo ${disk} | awk -F "/" '{print $NF}'`
	echo ${disk}
	echo ${VIR_NAME}
#	${VIRT_EXEC}  --name=${VIR_NAME} --boot network,cdrom,menu=on --ram ${VIRT_RAM} --vcpus=${VIRT_CPU} --cdrom=${KVM_ISO_DIR}  --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel6 --accelerate  --disk path=${KVM_IMAGE_DIR}/${i},size=5,format=qcow2,bus=virtio --bridge=br0,model=virtio  --autostart  --virt-type kvm
#	${VIRT_EXEC}  --name=${VIR_NAME} --boot network,cdrom,menu=on --ram ${VIRT_RAM} --vcpus=${VIRT_CPU} --cdrom=${KVM_ISO_DIR}  --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel6 --accelerate  -f ${disk} --bridge=br0,model=virtio  --autostart  --virt-type kvm
	${VIRT_EXEC}  --name=${VIR_NAME} --boot network,cdrom,menu=on --ram ${VIRT_RAM} --vcpus=${VIRT_CPU} --location=http://172.16.12.126/  --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel6 --accelerate  -f ${disk} --bridge=br0,model=virtio  --autostart  --virt-type kvm
done
