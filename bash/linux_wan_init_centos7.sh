#!/bin/bash
# author: by tommy
# date 2017-07-14
# version: 0.2
# description: system  zabbix ldap for centos 7
#

#系统初始化检查
system_check() {
echo "检查外网网络是否ok"
curl --connect-timeout 5  -I http://113.31.16.198:8889/zabbix/ > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo -e "\n \033[031m外网网络不通,请检查内网配置!\033[0m! \n"
        exit 1
else
        echo -e "\n \033[031m外网网络正常,继续.....\033[0m \n"
fi

echo -e "HOSTNAME:  `hostname` \n"
echo -e "HOSTIP  :  $HOSTIP \n"


if [ -d /usr/local/zabbix ]; then
        echo -e "Zabbix 监控已经安装！ \n"
else
        echo -e "Zabbix 监控未安装！ \n"
fi

idnum=`id user00|grep 20002|wc -l`
if [ ${idnum} -eq 1 ]; then
        echo -e "LDAP CLIENT 已经安装 !\n"
else
        echo -e "LDAP CLIENT 未安装 !\n"

fi
sleep 1

}

#进行系统初始化
yum_config(){
    yum install wget epel-release -y
    cd /etc/yum.repos.d/ && mkdir bak && mv -f *.repo bak/
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    yum clean all && yum makecache
}
#firewalld
iptables_config(){
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    yum install iptables-services -y
    systemctl enable iptables
    systemctl start iptables
    iptables -F
    service iptables save
}
#system config
system_config(){
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
    timedatectl set-local-rtc 1 && timedatectl set-timezone Asia/Shanghai
    yum -y install chrony && systemctl start chronyd.service && systemctl enable chronyd.service
}
ulimit_config(){
    echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       102400
*           hard   nofile       102400
*           soft   nproc        102400
*           hard   nproc        102400
EOF

}

#set sysctl
sysctl_config(){
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
EOF
    /sbin/sysctl -p
    echo "sysctl set OK!!"
}

system_init(){
    yum_config
    iptables_config
    system_config
    ulimit_config
    sysctl_config
}

#  系统初始化基本信息设置
system_set() {
LOCALHOST=`hostname`
ETCHOST=`grep $HOSTIP /etc/hosts|grep -v "#"`
if [ "$LOCALHOST" = "localhost.localdomain" -o -z "$ETCHOST" ] ;then
#配置主机名
	echo -e "\033[033m配置主机名:\033[0m\n"
	while true; do
		echo -e "\033[033m请输入机器主机名:\033[0m"
        	read HOSTNAME
        	echo -e "\033[031m确认主机名是 $HOSTNAME (y/n) ?\033[0m"
        	read y
                	if  [ "$y"  =  "y" ];then
                		break
                	else
                		echo -e "\033[031m请重新输入机器的主机名\033[0m"
                		continue
                	fi
	done
	#no ipv6
	sed -i '/localhost6/s/^/\#/' /etc/hosts
	echo -e "$HOSTIP \t\t $HOSTNAME" >> /etc/hosts
	#set network_hostname
	sed -i -e '/HOSTNAME/d' -e '/GATEWAY/d' /etc/sysconfig/network
	echo -e "HOSTNAME=$HOSTNAME" >> /etc/sysconfig/network
	/bin/hostname  $HOSTNAME

else
  	echo -e "\033[032m主机名已经设置 ! \033[0m\n"

fi

################disable selinux#################
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

#开启console
grep hvc0 /etc/grub.conf||sed -i 's/quiet/& console=hvc0/' /etc/grub.conf
grep hvc0 /etc/securetty||echo "hvc0" >>/etc/securetty
#关闭无用的服务
for service in kdump postfix lvm2-monitor messagebus quota_nld iptables  ip6tables abrt-ccpp abrt-oops abrtd;do chkconfig $service off ;done
#修改vim
grep vim  $HOME/.bashrc || sed  -i "/mv/aalias vi='vim'"  $HOME/.bashrc
grep zabbix  $HOME/.bashrc || sed  -i "/mv/aalias zabbix-restart='killall zabbix_agentd  && /usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf  && echo zabbix_agentd restart success. &&  ps aux |grep zabbix_agentd  ' "  $HOME/.bashrc
#修改历史命令格式
grep 10000 /etc/profile ||sed -i "/HISTSIZE/s/1000/10000/g" /etc/profile
grep HISTTIMEFORMAT /etc/profile ||echo -e 'export  HISTTIMEFORMAT="`whoami` : %F %T :"' >> /etc/profile
source /etc/profile
#添加同步时间
######################
\cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
crontab -l |grep ntpdate||echo -e  "0 * * * * /usr/sbin/ntpdate  210.72.145.44 64.147.116.229 time.nist.gov" >> /var/spool/cron/root
grep ntpdate /etc/rc.local ||echo -e  "/usr/sbin/ntpdate 210.72.145.44 64.147.116.229 time.nist.gov" >> /etc/rc.local
#修改系统连接数100W
grep 1000000 /etc/security/limits.conf||echo -e "*       soft    nofile  1000000\n*       hard    nofile  1000000\n*       soft    nproc   1000000\n*       hard    nproc   1000000\n" >> /etc/security/limits.conf
egrep  "net.ipv4.tcp_(tw_reuse|tw_recycle|fin_timeout|keepalive_time|max_syn_backlog)" /etc/sysctl.conf|| echo -e "fs.file-max = 1000000\nfs.nr_open = 1000000\nnet.ipv4.tcp_tw_reuse = 1\nnet.ipv4.tcp_tw_recycle = 1\nnet.ipv4.tcp_fin_timeout = 30\nnet.ipv4.tcp_keepalive_time = 1200\nnet.ipv4.ip_local_port_range = 1024 65000\nnet.ipv4.tcp_max_syn_backlog = 81920\nvm.swappiness = 10" >> /etc/sysctl.conf
#sed -i '/^net.bridge/s/^/#/' /etc/sysctl.conf
sed -i 's/1024/100000/g' /etc/security/limits.d/90-nproc.conf
echo -e "session    required     pam_limits.so" >> /etc/pam.d/login


#modify ssh
sed -i '/^#UseDNS/aUseDNS no' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g'  /etc/ssh/sshd_config
systemctl  restart sshd

#添加epel
rpm -Uvh http://113.31.16.198:8889/epel-release-6-8.noarch.rpm  >/dev/null 2>&1
sed -i 's/^mirrorlist/#mirrorlist/g'  /etc/yum.repos.d/epel.repo
sed -i 's/^#baseurl/baseurl/g'  /etc/yum.repos.d/epel.repo

#基础包安装
yum install -y bash openssl telnet mysql-libs dsniff dos2unix unix2dos tree wget lrzsz curl expect iotop iftop dstat  python-pip dmidecode bind-utils* iotop
yum groupinstall -y   "base"
#

#禁止外网IP直接登录.2014-04-01 ,如原来有增加清除重新增加
echo 'sshd:ALL EXCEPT 10.10.*,202.105.136.110,113.31.16.198,113.31.88.101,123.59.183.186'  > /etc/hosts.deny 
echo >/etc/hosts.allow 	
#Close atime
sed -i  '/data/s@defaults @defaults,noatime,nodiratime@'  /etc/fstab
chmod -R 700 /etc/rc.d/init.d/*    

################   ssh  ########################
ssh_cf="/etc/ssh/sshd_config" 
###set 60086####
sed -i 's/.*Port .*/Port 60086/' $ssh_cf
#   sed -i 's@.*ermitRootLogin .*@PermitRootLogin no@' $ssh_cf
sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
systemctl  restart sshd

##########################################################
ssh_client="/etc/ssh/ssh_config"
# CVE-2016-0777 && Update openssh for 7.1p2 or Set for This More information: http://www.openssh.com/txt/release-7.1p2
echo -e "## CVE-2016-0777\nUseRoaming no" >> ${ssh_client} && echo -e  "\e[1;32m Trun off Openssh Roaming Sucessed..\e[0m"
##########################################################
if grep "UseRoaming no" ${ssh_client}; then
	 echo -e  "\e[1;32m Openssh Patch is Repaired OK \e[0m"
fi

#########add manager user######################
sed -i '/so use_uid/s#\#auth#auth#' /etc/pam.d/su
grep -q 'source /etc/profile' /etc/bashrc  || echo 'source /etc/profile' >> /etc/bashrc
#root
echo 'cZHe$gPv*C0PosN'| passwd --stdin "root"   && history  -c
useradd -m -N -u 700 -g 100 ucpaasadmin
gpasswd  -a ucpaasadmin wheel
echo 'h31*M7o9CLC&!oYb'  |   passwd --stdin  ucpaasadmin && history  -c
#users
useradd -u 601 -g users developer
useradd -u 602 -M nginx -s /sbin/nologin
useradd -u 604 -g users im
useradd -u 605 -M zabbix -s /sbin/nologin
useradd -u 606 -g users  paas
useradd -u 607 -g users  vboss
useradd -u 608 -g users  message
useradd -u 610 -g users ipcc
useradd -u 611 -g users conference
  

mkdir /opt/{vboss,message,paas,ipcc,conference,im}
chown vboss.users  /opt/vboss
chown paas.users /opt/paas
chown ipcc.users /opt/ipcc
chown message.users /opt/message
chown conference.users /opt/conference
chown im.users /opt/im
}

#zabbix监控安装
zabbix_install() {
if [ -d /usr/local/zabbix ]; then
	echo -e "\033[032mZabbix 监控已经安装！ \033[0m\n"
else

	if [ -f /tmp/zabbix_centos6.tar.gz ];then
  		echo "##`date`#####START INSTALL ZABBIX_AGENT..."
  		rm -f /tmp/zabbix_centos6.tar.gz
  		wget http://113.31.16.198:8889/zabbix/zabbix_centos6.tar.gz -P /tmp
  		tar zxvf /tmp/zabbix_centos6.tar.gz -C /usr/local >/dev/null 2>&1
	else
  		echo "##`date`#####START INSTALL ZABBIX_AGENT..."
  		wget http://113.31.16.198:8889/zabbix/zabbix_centos6.tar.gz -P /tmp
  		tar zxvf /tmp/zabbix_centos6.tar.gz -C /usr/local >/dev/null 2>&1
	fi
	ZABBIXDIR=/usr/local/zabbix
	#添加zabbix用户
	userid=`grep zabbix /etc/passwd|wc -l`
	if [ $userid = 1 ];then
  		echo "zabbix user exist!"
	else
  		groupadd -g 605 zabbix
  		useradd -u 605 zabbix -M  -g zabbix -s /sbin/nologin
	fi
	chown -R zabbix.zabbix $ZABBIXDIR

	#配置 zabbix_agent
	HNAME=`hostname |awk -F'.' '{print $1}'`
	sed -i "/^SourceIP/s/10.10.16.198/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
	sed -i "/^Server/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
	sed -i "/^ServerActive/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
	sed -i "/^Hostname/s/Zabbix server/${HOSTIP}/" $ZABBIXDIR/etc/zabbix_agentd.conf
	sed -i "/^HostMetadata/s/51YZX/${hostmeta}/" $ZABBIXDIR/etc/zabbix_agentd.conf 

	#startup agentd
	procnum=`ps -ef |grep zabbix_agentd|grep -v grep |wc -l`
	if [ ${procnum} -gt 1 ]; then
  		killall -9 zabbix_agentd
	fi
	sleep 1
	/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf

	if [ $? = 0 ];then
  		echo "Zabbix_agentd start successful !"
  		rm -f /tmp/zabbix_centos6.tar.gz
	else
  		echo "Zabbix_agentd start failed !"
	fi

	grep zabbix /etc/rc.local  || echo "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf" >> /etc/rc.local
fi
}

#openLDAP客户端安装
ldap_install() {
##检测用户是否存在.
idnum=`id user00|grep 10003|wc -l`
if [ ${idnum} -eq 1 ]; then
  	echo "###`date`###LDAP CLIENT 已经安装,不需要重复执行."
  	exit 1
fi
#0.增加hosts
ldapnum=`grep -w "113.31.16.203  ldap01.51yzx.com" /etc/hosts|wc -l`
if [ ${ldapnum} -ne 1 ]; then 
  	echo "" >>/etc/hosts
  	echo "##ldap server info add. date:`date`	"             >>/etc/hosts
  	echo "113.31.16.203  ldap01.51yzx.com "                       >>/etc/hosts
  	echo "113.31.16.198  ldap02.51yzx.com "                       >>/etc/hosts
  	echo "##ldap server info add end."                            >>/etc/hosts
  	echo "" >>/etc/hosts
else
  	echo "`hostname` 机器可能已经配置LDAP客户端，不需要重复安装或者请手工检查.`date`"
  	exit 1
fi

#1.安装基本包
yum install openldap-clients nss-pam-ldapd sudo openssh-clients pam_ldap authconfig -y
#2.备份可能修改的文件
cp /etc/sysconfig/authconfig     /etc/sysconfig/authconfig.orig.${datestr}
cp /etc/nslcd.conf               /etc/nslcd.conf.orig.${datestr}
cp /etc/nsswitch.conf            /etc/nsswitch.conf.orig.${datestr}
cp /etc/pam_ldap.conf            /etc/pam_ldap.conf.orig.${datestr}
cp /etc/sudo-ldap.conf           /etc/sudo-ldap.conf.orig.${datestr}
cp /etc/openldap/ldap.conf       /etc/openldap/ldap.conf.orig.${datestr}
cp /etc/pam.d/password-auth-ac   /etc/pam.d/password-auth-ac.orig.${datestr}
cp /etc/pam.d/system-auth-ac     /etc/pam.d/system-auth-ac.orig.${datestr}

#使用系统自带配置
authconfig --updateall --enableldap --enableforcelegacy  --enableldapauth --ldapserver="ldaps://ldap01.51yzx.com ldaps://ldap02.51yzx.com " --ldapbasedn="dc=51yzx,dc=com" --enableldaptls --enableldapstarttls 
##文件替换使用ftp下载方式操作.
##A. /etc/nsswitch.conf 修改  正行替换，可以重复执行
sudoernum=`grep sudoer /etc/nsswitch.conf |wc -l`
if [ ${sudoernum} -eq 0 ]; then
	sed -i '/group:      files ldap/a\sudoers:    ldap'          /etc/nsswitch.conf 
  	sed -i 's/^services:   files*/services:   files ldap/g'      /etc/nsswitch.conf 
	echo "sudoers: files ldap" >> /etc/nsswitch.conf
fi
##B./etc/pam.d/password-auth修改增加初次登录创建home目录信息
##防止重复执行，需要判断是否存在.
execnum=`cat /etc/pam.d/password-auth|grep "session     optional      pam_mkhomedir.so skel=/etc/skel umask=0077"|wc -l`
if [ ${execnum} -gt 0 ]; then
	echo "#####`date`##### /etc/pam.d/password-auth 文件可能已经修改过,不需要重复添加."
else
  	insertnum=`cat /etc/pam.d/password-auth|grep "session     required      pam_limits.so"|wc -l`
  	##存在，增加信息
  	if [ ${insertnum} -eq 1 ]; then
    		sed -i '/session     required      pam_limits.so/a\session     optional      pam_mkhomedir.so skel=/etc/skel umask=0077' /etc/pam.d/password-auth
  	fi
fi
##C./etc/pam.d/system-auth,末行增加记录配置
execnum=`cat /etc/pam.d/system-auth|grep "session     required      pam_mkhomedir.so skel=/etc/skel umask=0077"|wc -l`
if [ ${execnum} -lt 1 ]; then	
 	 echo 'session     required      pam_mkhomedir.so skel=/etc/skel umask=0077' >> /etc/pam.d/system-auth
else
  	echo "#####`date`#####/etc/pam.d/system-auth文件可能已经修改过，不需要重复添加处理."
fi
##使用wget方式，需要保证http://113.31.16.198:8889/ldapclient_file/data/etc/可以访问.
##D. 证书文件下载复制
tmpdir='/root/tmp'
mkdir -pv ${tmpdir}
cd ${tmpdir}
wget http://113.31.16.198:8889/ldapclient_file/data/etc/openldap/cacerts/cacert.pem
cp -f cacert.pem /etc/openldap/cacerts
##E. /etc/openldap/ldap.conf
wget http://113.31.16.198:8889/ldapclient_file/data/etc/openldap/ldap.conf
cp -f ldap.conf /etc/openldap/ldap.conf
##F. /etc/sudo-ldap.conf
wget http://113.31.16.198:8889/ldapclient_file/data/etc/sudo-ldap.conf
cp -f sudo-ldap.conf /etc/sudo-ldap.conf
##G. /etc/pam_ldap.conf
wget http://113.31.16.198:8889/ldapclient_file/data/etc/pam_ldap.conf
cp -f pam_ldap.conf /etc/pam_ldap.conf
##H./etc/nslcd.conf
wget http://113.31.16.198:8889/ldapclient_file/data/etc/nslcd.conf
cp -f nslcd.conf /etc/nslcd.conf
##重启nslcd服务
systemctl  enable nslcd.service
systemctl  restart nslcd
systemctl  restart crond
##检测用户是否存在.
idnum=`id user00|grep 10003|wc -l`
if [ ${idnum} -eq 1 ]; then
  	echo "###`date`###LDAP CLIENT 安装成功.请登陆测试."
  	rm -rf ${tmpdir}
else
  	echo "###`date`###LDAP CLIENT 安装过程中可能出现问题.请手工检查."
fi
echo "#############`date`################END#################################"
}

main() {
        echo ---------------------------------
        echo -e "\033[31m服务器初始化配置脚本\033[0m"
        echo ---------------------------------
        echo -n "    ";echo "1:系统初始化安装(参数优化、ZABBIX监控、LDAP)"
        echo -n "    ";echo "2:系统参数优化"
        echo -n "    ";echo "3:添加ZABBIX监控"
        echo -n "    ";echo "4:安装LDAP"
        echo -n "    ";echo "5:系统初始化检测"
        echo -n "    ";echo "6:退出(q|Q|exit|5}"
        echo 
        echo ---------------------------------
        read -p "请选择你要进行的操作:" a

case $a in
        1)
        system_check
        system_init
        system_set
        zabbix_install
        ldap_install
        ;;
        2)
        system_check
        system_init
        ;;
        3)
        system_check
        system_init
        zabbix;;
        4)
        system_check
        system_init
        ldap
        ;;
        5)
        system_init
        ;;
        6|q|Q|exit)
        return 0
        ;;
        *)
	echo "Please input choice number.."
	exit 0
esac
}

main
#rm -f  $0
