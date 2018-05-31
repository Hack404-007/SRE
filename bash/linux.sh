#/bin/bash
# linux检查脚本1.1 20150907
export LANG=en_us.UTF8
OUTPUTDIR="`pwd`/linux"
if [ -z $1 ];then
	rm -rf $OUTPUTDIR 
	mkdir $OUTPUTDIR 
	echo "Rebuild $0"
	sh  "$0" 1 |tee "$OUTPUTDIR/linux.log"
	exit
fi

function loadIP(){
	ifconfig|grep "inet addr"|awk -F ":" '{print $2}'|awk -F " " '{if($1!="127.0.0.1"){print $1}}'
}

function loadVerison(){
	if [ -f "/etc/redhat-release" ]; then
		cat /etc/redhat-release
	else
		cat /proc/version
	fi	
}
function loadUser(){
	cat /etc/passwd|egrep "(/bin/bash|/bin/sh|/bin/ksh|/bin/dash)"|awk -F ":" '{print $1}'
}

function print(){
	echo "---------------------------------"
	echo ">"$1
}

#主机名
print "Hostname:"
hostname

#IP地址
print "IPADDR:"
loadIP

#内核版本
print "Linux Version:"
loadVerison

#安装程序列表
OUTPUTFILE="$OUTPUTDIR/installpackage"
echo "Install Progress Package:" > $OUTPUTFILE
rpm -qa >> $OUTPUTFILE

#进程列表
print "Progress Running List:"
ps -ef

#启动文件列表
print "Startup List:"
chkconfig --list

#启动文件
print "Startup Autorun File:"
cat /etc/rc.d/rc.local

#补丁记录
OUTPUTFILE="$OUTPUTDIR/yumlog"
echo "YUM Log:" > $OUTPUTFILE
cat /var/log/yum.log >> $OUTPUTFILE

#完整性检测工具
print "Integrity testing tool:"
which aide
which tripwire

#定时作业
print "Crontab Config:"
for item in `loadUser`
do
	echo "Crontab For $item"
	crontab -l -u $item
done

#登陆失败处理
print "Login Check Process:"
cat /etc/pam.d/system-auth-ac

#资源限制
print "Resource Limits:"
cat /etc/security/limits.conf

#访问控制
print "Host Allow List:"
cat /etc/hosts.allow

print "Host Deny List:"
cat /etc/hosts.deny

#审计策略
OUTPUTFILE="$OUTPUTDIR/audit.rules"
echo  "Audit Policy:">$OUTPUTFILE
cat /etc/audit/audit.rules >>$OUTPUTFILE

#日志记录配置
OUTPUTFILE="$OUTPUTDIR/rsyslog"
echo "Rsyslog Config:" >$OUTPUTFILE
cp /etc/rsyslog.conf  $OUTPUTFILE

#日志记录策略
cp -rf /etc/logrotate.* $OUTPUTDIR

#用户列表
print "User Logon List:"
loadUser

#sudo用户列表
print "Sudo Users:"
cat /etc/sudoers|grep "^[^#]"

#ssh配置
print "SSH Config:"
cat /etc/ssh/sshd_config |grep "^[^#]"

#资源标记

#系统环境变量
print "OS Profile:"
cat /etc/profile |grep "^[^#]"


#密码策略
print "Password Police:"
cat /etc/login.defs|grep "^[^#]"

#相同UID的用户
print "Common UID:"
cat /etc/passwd|awk -F ":" '{print $3}'|sort -n|uniq -c|awk -F " " '{if($1>1){print $2}}'

#空密码的用户
print "Empty Password User:"
for item in `loadUser`
do
	cat /etc/shadow|grep $item|awk -F ":" '{if (length($2)<=2){print $1}}'
done


#Selinux 配置
print "Selinux Config:"
cp -rf /etc/selinux $OUTPUTDIR
cp /etc/sestatus.conf $OUTPUTDIR
sestatus -b -v

#防火墙配置
print "Firewall Config:"
iptables-save

#文件权限检查
print "File Permission:"
ls -l /etc/rsyslog.conf
ls -l /etc/passwd
ls -l /etc/group
ls -l /etc/shadow
ls -l /etc/profile
ls -l /etc/sysctl.conf
ls -l /etc/hosts
ls -l /etc/hosts.allow
ls -l /etc/hosts.deny
ls -l /etc/resolv.conf
ls -l /etc/crontab*
ls -lR /etc/audit
ls -lR /var/log/
ls -lR /usr/bin
ls -lR /usr/local/bin
ls -lR /sbin
ls -lR /bin
ls -lR /usr/sbin
ls -lR /etc/logrotate.*



#登陆记录
print "LoginHistory:"
last




#入侵痕迹检查
print "IntrusionCheck:"
OUTPUTFILE="$OUTPUTDIR/securelog"
echo > $OUTPUTFILE
for item in `ls -1 /var/log/secure*`
do
	cat $item|grep "FAILURE" >> $OUTPUTFILE
done

for uitem in `loadUser`
do
	PDIR=`cat /etc/passwd|grep $uitem|awk -F ":" '{print $6}'`
	if [ ! -d "$PDIR" ]; then
		continue
	fi
	OUTPUTFILE=$PDIR"/"$uitem"_history"
	if [ -f "$PDIR/.bash_history" ];then
		cp "$PDIR/.bash_history" $OUTPUTFILE
	elif [ -f "$PDIR/.sh_history" ];then
		cp "$PDIR/.sh_history" $OUTPUTFILE
	fi
done


tar -zcf linux.tar.gz $OUTPUTDIR
rm -rf $OUTPUTDIR
#rm -rf $0
