#!/bin/bash
#
PV_CREATE=/sbin/pvcreate
VG_CREATE=/sbin/vgcreate
LV_CREATE=/sbin/lvcreate
LV_DISPL=/sbin/lvdisplay
VG_NAME=KVM
VG_SIZE=300G
VG_NAME_PRE=CentOS0
LV_PATH=$(${LV_DISPL} | grep "LV Path" | awk '{print $NF}')

# Create  LVM Volume Group
${PV_CREATE} /dev/sdb
${VG_CREATE} ${VG_NAME} /dev/sdb

# 
for i in $(seq 1 10); do
        ${LV_CREATE} -L ${VG_SIZE} -n ${VG_NAME_PRE}${i} ${VG_NAME}
done

echo "vgchange -ay"  >>/etc/init.d/boot.local

# mkfs.ext4 FileSystem Disk Format
for i in ${LV_PATH}; do
	mkfs.ext4 ${i}
done
