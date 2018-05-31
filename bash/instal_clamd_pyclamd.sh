#!/bin/bash
#

install_clamd()
{
	rpm -vih https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	yum install clamav clamd clamav-update -y
	chkconfig   --level 235 clamd on
	/usr/bin/freshclam
	sed -i '/^TCPAddr/{ s/127.0.0.1/0.0.0.0/; }' /etc/clamd.conf
	setenforce  0
	/etc/init.d/clamd  start

}

install_pyclamd()
{
	wget --no-check-certificate  https://pypi.python.org/packages/source/p/pyClamd/pyClamd-0.3.17.tar.gz#md5=701e63618e04f94d956e99e43372cf84
	tar zxvf pyClamd-0.3.17.tar.gz
	cd pyClamd-0.3.17
	python setup.py  install

}

install_nmap()
{
	yum install nmap -y
	wget --no-check-certificate  https://pypi.python.org/packages/source/p/python-nmap/python-nmap-0.5.0-1.tar.gz
	tar zxvf python-nmap-0.5.0-1.tar.gz
	cd python-nmap-0.5.0-1
	python setup.py install
	if [ "echo $?" = "0" ]; then
		echo "python-nmap install sucessed."
	else
		echo "Have a error You can check it."
	fi
}

main()
{
echo " "
cat <<EOF
+--------------------------------------------------------------+
|--------------- INSTALL CLAMD OR PYCLAMD FOR LINUX -----------|
+--------------------------------------------------------------+
EOF
echo -e "\033[32m |------------------------------------------------------------| \033[0m"
	echo "
		1) Install Clamd for Linux(Centos 6.x)
		2) Install Pyclamd for Linux(Centos 6.x)
		3) Install Nmap for Linux(Centos 6.x)
		4) Exit Install Guid.
	"
echo -e "\033[32m |------------------------------------------------------------| \033[0m"
	read -p "Please input You choice:" choice

	case "${choice}" in
		1)
		install_clamd
		;;
		2)
		install_pyclamd
		;;
		3)
		install_nmap
		;;
		4)
		echo "Exit install guid"
		exit 0
		;;
		*)
		echo "please input 1 or 2..."
		exit 0
		;;
	esac

}
main
