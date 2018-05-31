#!/bin/bash

#######################################################
# by Tommy
# 检查是否为root用户，脚本必须在root权限下运行 #
if [[ "$(whoami)" != "root" ]]; then
    echo "please run this script as root !" >&2
    exit 1
fi
echo -e "\033[31m the script only Support CentOS_6 x86_64 \033[0m"
echo -e "\033[31m system initialization script,press ctrl+C to cancel \033[0m"

# 检查是否为64位系统，这个脚本只支持64位脚本
platform=`uname -i`
if [ $platform != "x86_64" ];then
    echo "this script is only for 64bit Operating System !"
    exit 1
fi
echo "the platform is ok"

# 检查系统版本为centos 6
distributor=`lsb_release -i | awk '{print $NF}'`
version=`lsb_release -r | awk '{print substr($NF,1,1)}'`
if [ $distributor != 'CentOS' -o $version != '6' ]; then
    echo "this script is only for CentOS 6 !"
    exit 1
fi
# clear
cat << EOF
+---------------------------------------+
|   your system is CentOS 6 x86_64      |
|           start optimizing            |
+---------------------------------------+
EOF
sleep 3
 
 
# instll repo
yum_update(){
#make the 163.com as the default yum repo
if [ ! -e "/etc/yum.repos.d/bak" ]; then
    mkdir /etc/yum.repos.d/bak
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/bak/CentOS-Base.repo.backup
fi
 
#add
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo -O /etc/yum.repos.d/CentOS-Base.repo
 
#add the third-party repo
#rpm -Uvh http://download.Fedora.RedHat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
rpm -Uvh ftp://ftp.muug.mb.ca/mirror/centos/6.7/extras/x86_64/Packages/epel-release-6-8.noarch.rpm
#add the epel
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
 
#add the rpmforge
rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
 
#update the system
yum clean all && yum makecache
yum -y update glibc\*
yum -y update yum\* rpm\* python\*
yum -y update
echo -e "\033[31m yum update ok \033[0m"
sleep 1
}


#set the file limit
limits_config(){
#修改文件打开数
sed -i "/^ulimit -SHn.*/d" /etc/rc.local
echo "ulimit -SHn 102400" >> /etc/rc.local
 
sed -i "/^ulimit -s.*/d" /etc/profile
sed -i "/^ulimit -c.*/d" /etc/profile
sed -i "/^ulimit -SHn.*/d" /etc/profile
 
cat >> /etc/profile << EOF
#
#
#
ulimit -c unlimited
ulimit -s unlimited
ulimit -SHn 102400
EOF
 
source /etc/profile
ulimit -a
cat /etc/profile | grep ulimit
echo -e "\033[31m hosts ok \033[0m"
 
if [ ! -f "/etc/security/limits.conf.bak" ]; then
    cp /etc/security/limits.conf /etc/security/limits.conf.bak
fi
sed -i "/^*.*soft.*nofile/d" /etc/security/limits.conf
sed -i "/^*.*hard.*nofile/d" /etc/security/limits.conf
sed -i "/^*.*soft.*nproc/d" /etc/security/limits.conf
sed -i "/^*.*hard.*nproc/d" /etc/security/limits.conf
cat >> /etc/security/limits.conf << EOF
#
#
#
#
#---------custom-----------------------
#
*           soft   nofile       65535
*           hard   nofile       65535
*           soft   nproc        65535
*           hard   nproc        65535
EOF
cat /etc/security/limits.conf | grep "^*           .*"
echo -e "\033[31m limits ok \033[0m"
sleep 1
}

# tune kernel parametres #优化内核参数
sysctl_config(){
#delete
if [ ! -f "/etc/sysctl.conf.bak" ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
fi
sed -i "/^net.ipv4.ip_forward/d" /etc/sysctl.conf
sed -i "/^net.ipv4.conf.default.rp_filter/d" /etc/sysctl.conf
sed -i "/^net.ipv4.conf.default.accept_source_route/d" /etc/sysctl.conf
sed -i "/^kernel.sysrq/d" /etc/sysctl.conf
sed -i "/^kernel.core_uses_pid/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_syncookies/d" /etc/sysctl.conf
sed -i "/^kernel.msgmnb/d" /etc/sysctl.conf
sed -i "/^kernel.msgmax/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_max_tw_buckets/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_sack/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_window_scaling/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_rmem/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_wmem/d" /etc/sysctl.conf
sed -i "/^net.core.wmem_default/d" /etc/sysctl.conf
sed -i "/^net.core.rmem_default/d" /etc/sysctl.conf
sed -i "/^net.core.rmem_max/d" /etc/sysctl.conf
sed -i "/^net.core.wmem_max/d" /etc/sysctl.conf
sed -i "/^net.core.netdev_max_backlog/d" /etc/sysctl.conf
sed -i "/^net.core.somaxconn/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_max_orphans/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_max_syn_backlog/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_timestamps/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_synack_retries/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_syn_retries/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_tw_recycle/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_tw_reuse/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_mem/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_fin_timeout/d" /etc/sysctl.conf
sed -i "/^net.ipv4.tcp_keepalive_time/d" /etc/sysctl.conf
sed -i "/^net.ipv4.ip_local_port_range/d" /etc/sysctl.conf
#sed -i "/^net.ipv4.tcp_tw_len/d" /etc/sysctl.conf
 
#add
cat >> /etc/sysctl.conf << EOF
#
#
#
#
#-------custom---------------------------------------------
#
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096    87380   4194304
net.ipv4.tcp_wmem = 4096    16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_synack_retries = 2
#net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
#net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024    65535
#net.ipv4.tcp_tw_len = 1
EOF
 
#buckets
echo 6000 > /proc/sys/net/ipv4/tcp_max_tw_buckets
 
#delete
sed -i "/^kernel.shmmax/d" /etc/sysctl.conf
sed -i "/^kernel.shmall/d" /etc/sysctl.conf
 
#add
shmmax=`free -l |grep Mem |awk '{printf("%d\n",$2*1024*0.9)}'`
shmall=$[$shmmax/4]
echo "kernel.shmmax = "$shmmax >> /etc/sysctl.conf
echo "kernel.shmall = "$shmall >> /etc/sysctl.conf
 
#bridge
modprobe bridge
lsmod|grep bridge
 
#reload sysctl
/sbin/sysctl -p
echo -e "\033[31m sysctl ok \033[0m"
sleep 1
}

#disable selinux #关闭SELINUX
selinux(){
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
echo -e "\033[31m selinux ok \033[0m"
sleep 1
}

#set sshd_config UseDNS
ssh_GSS(){
#sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i '/^#UseDNS/s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart
cat /etc/ssh/sshd_config | grep -i usedns
cat /etc/ssh/sshd_config | grep -i PermitEmptyPasswords
echo -e "\033[31m sshd ok \033[0m"
sleep 1
}

#disable some service
dissable_service() {
#关闭无用的服务
   for service in kdump postfix lvm2-monitor messagebus quota_nld iptables ip6tables abrt-ccpp abrt-oops abrtd bluetooth cups;do chkconfig $service off ;done
}

stop_ipv6(){
cat > /etc/modprobe.d/ipv6.conf << EOFI
#
#
#
#---------------custom-----------------------
#
alias net-pf-10 off
options ipv6 disable=1
EOFI

zone_time() {
#添加时间同步
	yum install ntp -y
   cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
   crontab -l |grep ntpdate||echo -e  "0 * * * * /usr/sbin/ntpdate  210.72.145.44 64.147.116.229 time.nist.gov" >> /var/spool/cron/root
   grep ntpdate /etc/rc.local ||echo -e  "/usr/sbin/ntpdate 210.72.145.44 64.147.116.229 time.nist.gov" >> /etc/rc.local
}

#sed -i '/^net.bridge/s/^/#/' /etc/sysctl.conf
   sed -i 's/1024/100000/g' /etc/security/limits.d/90-nproc.conf
   echo -e "session    required     pam_limits.so" >> /etc/pam.d/login

install_base(){
#基础包安装
   yum install -y bash openssl telnet mysql-libs dsniff dos2unix unix2dos tree wget lrzsz curl expect iotop iftop dstat python-pip dmidecode bind-utils* iotop openssl-client gcc gcc-c++
   yum groupinstall -y   "base"
}

## echo "更改网卡从emx ===> ifcfg-ethx"
Modify_physical()
{
	Network=$(dmesg  | grep "renamed network" | awk '{print $7":"$5}')
	echo "$Network" > tmp.txt
	grep -E  "em1|em2|em3|em4" tmp.txt > /dev/null
	if [ $? -eq 0 ]; then
        	echo "Found em network."
	else
        	echo "Not Found it.."
        	exit 0
	fi

	for i in $Network; do
        	em=$(echo $i | awk -F ":" '{print $1}')
        	eth=$(echo $i | awk -F ":" '{print $2}')
        	echo "mv ifcfg-$em to ifcfg-$eth"
        	cd /etc/sysconfig/network-scripts/
		#echo $PWD
        	mv ifcfg-$em ifcfg-$eth
        	sed -i "s/DEVICE=$em/DEVICE=$eth/" ifcfg-$eth
        	sed -i '/^NAME/d' ifcfg-$eth
	done

	echo "删除相关配置文件"
	cp /etc/udev/rules.d/70-persistent-net.rules  /root/udev_bak-70-persistent-net.rules
	rm -f /etc/udev/rules.d/70-persistent-net.rules

}

done_ok(){
cat << EOF
+-------------------------------------------------+
|               Optimizer is Done                 |
|   It's Recommond to Restart this Server !       |
|                                                 |
|             Please Reboot System                |
+-------------------------------------------------+
EOF
}


# 调用函数
# main
main(){
    yum_update
    limits_config
    sysctl_config
    selinux
    ssh_GSS
    dissable_service
    stop_ipv6
    zone_time
    install_base
    Modify_physical
    done_ok
}

main
exit 0





