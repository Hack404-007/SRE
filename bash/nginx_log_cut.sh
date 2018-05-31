#!/bin/sh

logs_path=/usr/local/nginx/logs
yesterday=`date -d 'yesterday' +%F`
olddate=`date -d '7 days ago' +%F`
mkdir -p $logs_path/log-bak/$yesterday

cd $logs_path

for nginx_logs in `ls *.log`;do
	mv $nginx_logs log-bak/${yesterday}/${yesterday}-${nginx_logs}
	gzip log-bak/${yesterday}/${yesterday}-${nginx_logs}
	kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
done

/etc/init.d/nginx reload

cd log-bak && rm -rf ${olddate}
