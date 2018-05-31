#!/bin/bash

wget http://www.keepalived.org/software/keepalived-1.2.18.tar.gz
tar -xvzf keepalived-1.2.18.tar.gz

yum install openssl*  gcc popt*    gcc openssl-devel

cd   keepalived-1.2.18  
./configure --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 --libexecdir=/usr/libexec --localstatedir=/var --mandir=/usr/share/man --infodir=/usr/share/info --sharedstatedir=/usr/com --with-kernel-dir=/usr/src/linux &&  make   &&  make install  && ldconfig 

/etc/init.d/keepalived restart

wget http://113.31.16.198:8889/keepalive/nginx_check.sh -P /etc/keepalived/

wget http://113.31.16.198:8889/nginx/nginx_install.sh
 
sh nginx_install.sh
