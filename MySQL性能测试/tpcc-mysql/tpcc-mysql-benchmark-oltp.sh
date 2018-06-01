#!/bin/bash
##
## ִ��tpcc mysql OLTP��׼����
##
## writed by yejr(http://imysql.com), 2012/12/14
##

#export LD_LIBRARY_PATH=/usr/local/mysql/lib/

. ~/.bash_profile >/dev/null 2>&1

#set -u
#set -x
#set -e

BASEDIR="/home/tpcc-mysql"
cd $BASEDIR

exec 3>&1 4>&2 1>> tpcc-mysql-benchmark-oltp-`date +'%Y%m%d%H%M%S'`.log 2>&1

#ִ��tpcc���Ե����ݿ�IP
DBIP=localhost
DBUSER='tpcc'
DBPASS='tpcc'
#����ģʽ��1000���ֿ�
WIREHOUSE=1000
DBNAME="tpcc${WIREHOUSE}"
#����Ԥ��ʱ�䣺120��
WARMUP=120
#ִ�в���ʱ����1Сʱ
DURING=3600
#����ģʽ
MODE="2SSD_RAID0_WB_nobarrier_deadline"

#��ʼ�����Ի���
if [ -z "`mysqlshow|grep -v grep|grep \"$DBNAME\"`" ] ; then
 mysqladmin -f create $DBNAME
 mysql -e "grant all on $DBNAME.* to $DBUSER@'$DBIP' identified by '$DBPASS';"
 mysql -f $DBNAME < ./create_table.sql
 ./tpcc_load $DBIP $DBNAME $DBUSER $DBPASS $WIREHOUSE
fi

CNT=0
CYCLE=2
while [ $CNT -lt $CYCLE ]
do
NOW=`date +'%Y%m%d%H%M'`
#���Բ����̣߳�8 ~ 256
for THREADS in 8 16 32 64 128 256
do

#��ʼִ��tpcc����
./tpcc_start -h $DBIP -d $DBNAME -u $DBUSER -p "${DBPASS}" -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURING -f ./logs/tpcc_${MODE}_${NOW}_${THREADS}_THREADS.res >> ./logs/tpcc_runlog_${MODE}_${NOW}_${THREADS}_THREADS 2>&1

#����mysqld
/etc/init.d/mysql stop; echo 3 > /proc/sys/vm/drop_caches; /etc/init.d/mysql start; sleep 60
done

CNT=`expr $CNT + 1`
done
