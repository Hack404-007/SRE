#!/bin/bash
#
T_Date=`date +"%F %T"`
#while :
#do
	fdfs_pid=$(ps -ef | grep "/usr/local/bin/fdfs_" | grep -v grep | wc -l)
	if [ "$fdfs_pid" == "2" ]; then
		echo "FastDfs is running..$T_Date"
	else
		echo "FastDfs is not  running..$T_Date"
		/usr/local/bin/fdfs_trackerd  /etc/fdfs/tracker.conf
		/usr/local/bin/fdfs_storaged  /etc/fdfs/storage.conf
		/usr/local/monitor/sendsms/sendsms.sh "FastDfs is restart ok"

#		for pid in `ps -ef | grep -E  'fdfs_trackerd|fdfs_storaged' | grep -v grep | awk '{print $2}'`; do
#			kill -9 $pid
#		done	
#		/usr/local/bin/fdfs_trackerd  /etc/fdfs/tracker.conf 
#		/usr/local/bin/fdfs_storaged  /etc/fdfs/storage.conf
#		/usr/local/monitor/sendsms/sendsms.sh "FastDfs is restart ok"
	fi
#	sleep 5

#done
		

