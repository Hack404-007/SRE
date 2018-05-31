#!/bin/bash
# description: autodeploy django project "ewo_oms"
# auther: ywzhou
# modify: 2016/08/29

# install
rpm -Uvh 
yum install -y wget gcc zlib zlib-devel openssl openssl-devel tigervnc-server "@Chinese Support"  git subversion mysql mysql-server mysql-devel MySQL-python
# vnc
echo "VNC_PASSWORD" | vncserver --stdin
iptables -I INPUT -p tcp --dport 5901 -j ACCEPT && service iptables save
# python update
cd /usr/local/src
wget https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz
tar -zxvf Python-2.7.11.tgz
cd Python-2.7.11
./configure
make
make install
mv /usr/bin/python /usr/bin/python_old
ln -s /usr/local/bin/python /usr/bin/
sed -i 's@#!/usr/bin/python@#!/usr/bin/python2.6@' /usr/bin/yum
# pip
cd /usr/local/src
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
ln -s /usr/local/python27/bin/pip /usr/bin/
pip install Django==1.8.7 svn
# mysql-python
wget http://sourceforge.net/projects/mysql-python/files/mysql-python/1.2.3/MySQL-python-1.2.3.tar.gz
tar zxf MySQL-python-1.2.3.tar.gz
cd MySQL-python-1.2.3
python setup.py build
python setup.py install
#mysql
service mysqld start
chkconfig mysqld on
mysql -uroot -e"set password for root@localhost=password('abc@123')"
mysql -uroot -pabc@123 -e"drop database ewp_oms"
mysql -uroot -pabc@123 -e"create database ewp_oms character set utf8"
mysql -uroot -pabc@123 -e"grant all on ewp_oms.* to 'admin'@'localhost' identified by 'abc@123'"
# ewp_oms
cd /
git clone https://github.com/ywzhou123/EWP_OMS.git
cd /EWP_OMS
python manage.py migrate
echo "enter superuser password to login web"
python manage.py createsuperuser --username admin --email admin@localhost.com
python manage.py runserver localhost:8000
iptables -I INPUT -p tcp --dport 5901 -j ACCEPT 
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
service iptables save
