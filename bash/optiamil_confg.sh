#!/bin/bash
#
# Name:optiamil_confg.sh
# Description: reset password for root &&  yum update somene
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-01-15 15:41:23
# Usage: sh optiamil_confg.sh | ./optiamil_confg.sh

cat << EOF
+-----------------------------------------------------------------------------------------------------------------------+
|   ===============================  Reset User Password For root && Update Package Patch ==========================    |
+-----------------------------------------------------------------------------------------------------------------------+
EOF

sudo_User=ucpaasadmin
sudo_File=/etc/sudoers
sshd_File=/etc/ssh/sshd_config
ssh_File=/etc/ssh/ssh_config
log_File=$(pwd)/update.log

backup_ssh_File()
{
	cp ${sshd_File} /etc/ssh/sshd_config_default
	cp ${ssh_File}  /etc/ssh/ssh_config_default
}
add_sudo_user()
{
	if ! cat /etc/passwd | grep ${sudo_User} &> /dev/null; then
		/usr/sbin/useradd  ${sudo_User}
	fi

	/bin/echo "keepc.com" | passwd --stdin ${sudo_User}  && history -c
	sed -i '108a\${sudo_User}    ALL=(ALL)       NOPASSWD: ALL' ${sudo_File}
}


resetroot()
{
	echo "Rest Password For root"
	/bin/echo "GwO2kkHe\$gHzjaSy" | passwd --stdin root  && history -c

	if sed -n '/PermitRootLogin no/p' ${sshd_File} | grep "PermitRootLogin no" &> /dev/null; then
		sed -i '/PermitRootLogin no/s/PermitRootLogin no/PermitRootLogin yes/' ${sshd_File}
	else
		echo -e  "\e[1;32m This Host is PermitrootremoteLogin.\e[0m"
		sleep 10
	fi
	
	service sshd restart &&  echo -e "\e[1;31m SSH Service Have Error, Please check it..\e[0m"
}

update_package()
{
	for package in openssl openssh glibc
	do
		yum update $package
		sleep 3
	done
	
	##########################################################
	# CVE-2016-0777 && Update openssh for 7.1p2 or Set for This More information: http://www.openssh.com/txt/release-7.1p2
	echo -e "## CVE-2016-0777\nUserRoaming no" >> ${ssh_File}
	##########################################################
	if grep "UserRoaming no" ${ssh_File}; then
		echo -e  "\e[1;32m Openssh Patch is Repaired OK \e[0m"
	fi
	service sshd restart
	sleep 3

	NGINX_EXEC=$(ps -ef |grep nginx | grep ^root | grep -v grep | awk  '{print $11}')
	if [ `ps -ef | grep nginx | grep -v grep | wc -l` -le 0 ]; then
		echo -e  "\e[1;31m This Host Not Running Nginx..\e[0m"
		return 13
	else
		$NGINX_EXEC -s reload && echo -e  "\e[1;32m Nginx Reload is Sucessed..\e[0m"
		sleep 10
	fi
		

}

update_openssl_source()
{
	echo "安装依赖包"
	yum install -y zlib
	echo "下载源码包"

	wget http://10.10.16.198:8889/openssl/openssl-1.0.2e.tar.gz
	tar zxvf openssl-1.0.2e.tar.gz
	cd openssl-1.0.2e
	./config shared zlib
	make
	make install

	echo "重设动态链接库"
	mv /usr/bin/openssl /usr/bin/openssl.OFF
	mv /usr/include/openssl /usr/include/openssl.OFF
	ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
	ln -s /usr/local/ssl/include/openssl /usr/include/openssl

	#配置库文件搜索路径
	echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
	ldconfig -v &> /dev/null

	#查看openssl版本号，验证安装正确性
	if ! /usr/bin/openssl version -a | grep built | grep 2014 &> dev/null; then
		echo ""
		echo -e  "\e[1;32m Update Openssl Source Sucessed.\e[0m"
		sleep 10
	else
		echo  -e "\e[1;31m Please check it Error.\e[0m"
	fi
}


clear_history()
{
	sed  -i 's/export PROMPT_COMMAND/#export PROMPT_COMMAND/' /etc/bashrc
	sed  -i "s/^export logfromat.*/export logfromat=$\(who -um | awk -F '[ \(\)]' '{printf(\"%s@%s|PID[%s]#[LOGIN:%s %s]\",\$1,\$26,\$24,\$11,\$12)}');export logfromat/"   /etc/bashrc
	source  /etc/profile

}

echo "函数调用"
#备份配置恩建
backup_ssh_File

#创建sudo用户
#add_sudo_user

#设置root密码
resetroot

#升级补丁包
update_package

#源码升级Openssl
#update_openssl_source

#清除国领审计命令
clear_history
