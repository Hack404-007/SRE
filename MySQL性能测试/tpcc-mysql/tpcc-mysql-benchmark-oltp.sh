#!/bin/bash
##
## 执行tpcc mysql OLTP基准测试
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

#执行tpcc测试的数据库IP
DBIP=localhost
DBUSER='tpcc'
DBPASS='tpcc'
#测试模式：1000个仓库
WIREHOUSE=1000
DBNAME="tpcc${WIREHOUSE}"
#数据预热时间：120秒
WARMUP=120
#执行测试时长：1小时
DURING=3600
#测试模式
MODE="2SSD_RAID0_WB_nobarrier_deadline"

#初始化测试环境
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
#测试并发线程：8 ~ 256
for THREADS in 8 16 32 64 128 256
do

#开始执行tpcc测试
./tpcc_start -h $DBIP -d $DBNAME -u $DBUSER -p "${DBPASS}" -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURING -f ./logs/tpcc_${MODE}_${NOW}_${THREADS}_THREADS.res >> ./logs/tpcc_runlog_${MODE}_${NOW}_${THREADS}_THREADS 2>&1

#重启mysqld
/etc/init.d/mysql stop; echo 3 > /proc/sys/vm/drop_caches; /etc/init.d/mysql start; sleep 60
done

CNT=`expr $CNT + 1`
done
