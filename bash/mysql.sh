#!/bin/bash
export LANG=en_us.UTF8
OUTPUTDIR="`pwd`/mysql"
if [ -z $1 ];then
	rm -rf $OUTPUTDIR 
	mkdir $OUTPUTDIR 
	echo "Rebuild $0"
	sh  "$0" 1 |tee "$OUTPUTDIR/mysql.log"
	exit
fi


echo -n "Config Path:"
read CONFPATH
cp $CONFPATH $OUTPUTDIR
ls -l $CONFPATH

echo -n "Mysql Path:"
read MYSQLPATH
if [ ! -z $MYSQLPATH -a -d $MYSQLPATH ];then
	ls -l $MYSQLPATH
fi

if [ -d "/var/lib/mysql" ]; then
	echo "/var/lib/mysql"
	ls -l /var/lib/mysql
else
	echo -n "Mysql Data Path:"
	read DATAPATH
	ls -l $DATAPATH
fi

echo "--------------------------------"
/data/soft/mysql-ucpaas/bin/mysql  -u root -S /tmp/mysql-ucpaas.sock  -p  -t <<EOF
show variables like '%log%';
show variables like '%ssl%';
show variables like '%version%';
select user,host, if(count(distinct password)<count(password),"Y","N") as commonpwd from mysql.user group by host;
select user,host,ssl_type,ssl_cipher,x509_issuer,x509_subject,max_questions,max_updates,max_connections,max_user_connections from mysql.user;
select * from information_schema.SCHEMA_PRIVILEGES;
select * from information_schema.TABLE_PRIVILEGES;
select * from information_schema.COLUMN_PRIVILEGES;
EOF


tar -zcf mysql.tar.gz $OUTPUTDIR
rm -rf $OUTPUTDIR
