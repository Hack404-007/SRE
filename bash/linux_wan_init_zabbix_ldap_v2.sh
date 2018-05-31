#!/bin/bash
#2015-07-15
hostmeta=$1

if [ $# -ne 1 ];then
  #echo "Usage: $0 hostmetadata. such as: $0 hostmetadata)"
  echo "init.sh Ver 8.21.1500

USEAGE:

        bash \$0 \$1
        \$1           hostmetadata参数,可以接的参数为51YZX OTT ZSRJ VBOSS GZNFJD 分别对应北京兆维,OTT,中山睿江,VBOSS,广州南方基地

example:

        bash \$0 OTT       --初始化机器,并修改zabbix-agent的hoatmetadata为OTT"
  exit 7
fi

echo "#####`date`##### 首先清理安装系统遗留的系统文件...."
rm -f /root/cobbler.ks
rm -f /root/anaconda-ks.cfg
rm -f /tmp/ks-script-*

echo "##########该初始化操作不涉及任何用户密码处理操作.切记注意!!!!###############"

SERVERIP=113.31.16.198
HOSTIP=`/sbin/ifconfig |awk '/inet addr:/{print $2;exit}'|sed 's/addr://'`

if [ `echo $HOSTIP` = "" ]
then
   echo "无法获取eth0/em1外网ip,请检查网卡配置！"
   exit 1
else
   echo "内网IP：$HOSTIP ,ZABBIX服务器IP: $SERVERIP "
fi

echo -e "\033[031m确认在本机执行,IP:$HOSTIP (y/n) ?\033[0m"
read y
if  [ "$y"  =  "y" ];then
       echo "Starting ... ..."
else
       echo -e "\033[031m程序退出，请检查服务器\033[0m"
       exit 1
fi

info ()
{
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
	#check;
	system;
	zabbix;
	ldap;;
	2)
	#check;
	system;;
	3)
	#check;
	zabbix;;
	4)
	#check;
	ldap;;
	5)
	check;;
	6|q|Q|exit)
	return 0 ;;
	*)
	info;;
	
esac

}

check() {
echo "检查外网网络是否ok"

curl --connect-timeout 5  -I http://113.31.16.198:8889/zabbix/ > /dev/null 2>&1

if [ $? -ne 0 ];then
	echo -e "\n \033[031m外网网络不通,请检查内网配置!\033[0m! \n"
	exit 1
else
	echo -e "\n \033[031m外网网络正常,继续.....\033[0m \n"
fi

echo -e "HOSTNAME:  `hostname` \n"
echo -e "HOSTIP  :  $HOSTIP \n"

if  [ -f /etc/pxeinit_wan] ;then
	echo -e "系统参数已经优化! \n"
else 
	echo -e "系统参数未经过优化! \n"
fi


if [ -d /usr/local/zabbix ];then
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
system ()
{

LOCALHOST=`hostname`
ETCHOST=`grep $HOSTIP /etc/hosts|grep -v "#"`
if [ "$LOCALHOST" = "localhost.localdomain" -o -z "$ETCHOST" ] ;then

#配置主机名
   echo -e "\033[033m配置主机名:\033[0m\n"
   while 
   true
        do
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

#判断是否已经初始化
if  [ -f /etc/pxeinit_wan ] ;then
  echo -e "\033[032m系统参数已经优化\033[0m \n"

else

################disable selinux#################
   sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

#开启console
   grep hvc0 /etc/grub.conf||sed -i 's/quiet/& console=hvc0/' /etc/grub.conf
   grep hvc0 /etc/securetty||echo "hvc0" >>/etc/securetty
#关闭无用的服务
   for service in kdump postfix lvm2-monitor messagebus quota_nld iptables  ip6tables abrt-ccpp abrt-oops abrtd;do chkconfig $service off ;done
#修改vim
   grep vim  $HOME/.bashrc || sed  -i "/mv/aalias vi='vim'"  $HOME/.bashrc
#修改历史命令格式
   grep 10000 /etc/profile ||sed -i "/HISTSIZE/s/1000/10000/g" /etc/profile
   grep HISTTIMEFORMAT /etc/profile ||echo -e 'export  HISTTIMEFORMAT="`whoami` : %F %T :"' >> /etc/profile
   source /etc/profile
#添加同步时间
######################
   cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
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
   /etc/init.d/sshd restart

#添加epel
   rpm -Uvh http://113.31.16.198:8889/epel-release-6-8.noarch.rpm  >/dev/null 2>&1
sed -i 's/^mirrorlist/#mirrorlist/g'  /etc/yum.repos.d/epel.repo
sed -i 's/^#baseurl/baseurl/g'  /etc/yum.repos.d/epel.repo

#基础包安装
   yum install -y bash openssl telnet mysql-libs dsniff dos2unix unix2dos tree wget lrzsz curl expect iotop iftop dstat  python-pip dmidecode bind-utils* iotop
   yum groupinstall -y   "base"
#

#禁止外网IP直接登录.2014-04-01 ,如原来有增加清除重新增加
   #sed -i '/sshd:ALL EXCEPT/d' /etc/hosts.deny   
   echo 'sshd:ALL EXCEPT 10.10.*,202.105.136.110,113.31.16.198,113.31.88.101'  > /etc/hosts.deny 
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

   /etc/init.d/sshd restart


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
   echo 'GwO2kkHe$gHzjaSy'| passwd --stdin "root"
   
   useradd -m -N -u 700 -g 100 ucpaasadmin
   gpasswd  -a ucpaasadmin wheel
   echo 'h31*M7o9CLC&!oYb'  |   passwd --stdin  ucpaasadmin

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



#close ctrl+alt+del#
  sed -i 's/^/#/' /etc/init/control-alt-delete.conf

  echo "" >>/etc/pxeinit_wan



fi
}


zabbix ()
{
if [ -d /usr/local/zabbix ];then
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
sed -i "/^Hostname/s/Zabbix server/${HOSTIP}-${HNAME}/" $ZABBIXDIR/etc/zabbix_agentd.conf
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

#


}

ldap () 
{

if [ -f /tmp/ldap_client_centos6.3.sh ] ;then
 
sh /tmp/ldap_client_centos6.3.sh

else
wget http://113.31.16.198:8889/ldapclient_file/data/ldap_client_centos6.3.sh -P /tmp 

	if [ $? -ne 0 ];then
	echo "下载 ldap_client_centos6.3.sh 失败 ！"
	else 
	sh /tmp/ldap_client_centos6.3.sh 
	fi
fi
 rm -f /tmp/ldap_client_centos6.3.sh
}

info
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

	echo "修改配置文件成功，请确认重启^_()_^"

}

#Modify_physical

echo "修改完成，确认检查下网卡配置文件.."

rm -f $0
