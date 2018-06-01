#!/bin/sh
##
## ִ��sysbench��������׼���ԣ�����: CPU, �ڴ�, �߳�, MUTEX, ����IO, OLTP
##
## writed by yejr(http://imysql.com), 2012/12/04
##
 
PATH=$PATH:/usr/local/bin
export PATH
 
set -u
set -x
set -e
 
 
# {{{ ���ֲ���
WORKDIR=/home/sysbench
cd ${WORKDIR}
 
exec 3>&1 4>&2 1>> sysbench_benchmark_cpu_memory_fileio_oltp-`date +'%Y%m%d%H%M%S'`.log 2>&1
 
SLEEP_SEC=120
MAX_REQUEST=5000000
 
#mutex
MUTEX_NUM=5000000
MUTEX_LOCK=100000
MUTEX_LOOP=100000
 
#thread
NUM_THREADS="4 8 16 32 64 128 256 512"
THREAD_LOCKS="4 8 16 32 64 128 256 512"
THREAD_YIELD=5000000
 
#oltp
OLTP_SIZE=100000000
OLTP_TBL="INNODB_1Y"
OLTP_DB_HOST=localhost
OLTP_DB_USER=root
OLTP_DB_PASSWD=""
OLTP_DB_SOCKET=/tmp/mysql.sock
OLTP_MODE="complex"
OLTP_DB_ENGINE="innodb"
OLTP_DB_SIZE=100000000
OLTP_DB_TBL="INNODB_1Y"
OLTP_DB_DBNAME=test
 
#cpu
CPU_MAX_PRIME=5000000
 
#memory
MEM_BLK_SIZE="4096 8192 16384 32768 65536 131072 262144 524288 1048576"
# }}}
 
 
# {{{ OLTP:MySQL
OLTP()
{
#WRITELOG oltp
 
#�Լ�
ii=1
while [ "`mysqladmin ping`" != "mysqld is alive" ] && [ $ii -lt 100 ]
do
 sleep 10
 echo "mysqld is no alive, sleep 10"
 /etc/init.d/mysql start
 ii=`expr $ii + 1`
done
 
#��ʼ��
if [ -z "`mysqlshow | grep ' test '`" ] ; then
 mysqladmin create test
fi
 
if [ -z "`mysqlshow test | grep \" ${OLTP_DB_TBL} \"`" ] ; then
time sysbench --mysql-user=${OLTP_DB_USER} --test=oltp --mysql-host=${OLTP_DB_HOST} --mysql-socket=${OLTP_DB_SOCKET} \
--oltp-test-mode=${OLTP_MODE} --mysql-table-engine=${OLTP_DB_ENGINE} --oltp-table-size=${OLTP_DB_SIZE} --mysql-db=test \
--oltp-table-name=${OLTP_DB_TBL} --max-requests=${MAX_REQUEST} prepare
fi
 
#��ʼ����
for THREADS in ${NUM_THREADS}
do
  sysbench --mysql-user=${OLTP_DB_USER} --test=oltp --mysql-host=${OLTP_DB_HOST} --mysql-socket=${OLTP_DB_SOCKET} \
--oltp-test-mode=${OLTP_MODE} --mysql-table-engine=${OLTP_DB_ENGINE} --oltp-table-size=${OLTP_DB_SIZE} --mysql-db=test \
--oltp-table-name=${OLTP_DB_TBL} --num-threads=${THREADS} --max-requests=${MAX_REQUEST} run
done
}
# }}}
 
# {{{ MEMORY
MEMORY()
{
#WRITELOG memory
 
PHY_MEM=`grep MemTotal: /proc/meminfo|awk '{print $2}'`
 
#�����ڴ���Դ�С,һ��Ϊ�����ڴ��2��
#8G����
if [ $PHY_MEM -gt 8088608 ] && [ $PHY_MEM -lt 8388608 ] ; then
 MEM_SIZE='32G'
#16G����
elif [ $PHY_MEM -gt 14777216 ] && [ $PHY_MEM -lt 16777216 ] ; then
 MEM_SIZE='64G'
#32G����
elif [ $PHY_MEM -gt 31554432 ] && [ $PHY_MEM -lt 33554432 ] ; then
 MEM_SIZE='128G'
#64G
elif [ $PHY_MEM -gt 67008864 ] && [ $PHY_MEM -lt 67208864 ] ; then
 MEM_SIZE='256G'
#96G
elif [ $PHY_MEM -gt 100063296 ] && [ $PHY_MEM -lt 110663296 ] ; then
 MEM_SIZE='392G'
#128G
elif [ $PHY_MEM -gt 110520696 ] && [ $PHY_MEM -lt 116520696 ] ; then
 MEM_SIZE='512G'
else
 MEM_SIZE='8G'
fi
 
for THREADS in ${NUM_THREADS}
do
  for BLOCK in ${MEM_BLK_SIZE}
  do
    sysbench --test=memory --memory-access-mode=rnd --memory-total-size=${MEM_SIZE} --memory-block-size=${BLOCK} --memory-oper=read  --num-threads=${THREADS} --max-requests=${MAX_REQUEST} run >> sysbench_mem_rnd_read_total{${MEM_SIZE}}_blk{${BLOCK}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
    sysbench --test=memory --memory-access-mode=rnd --memory-total-size=${MEM_SIZE} --memory-block-size=${BLOCK} --memory-oper=write --num-threads=${THREADS} --max-requests=${MAX_REQUEST} run >> sysbench_mem_rnd_write_total{${MEM_SIZE}}_blk{${BLOCK}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
  done
done
}
# }}}
 
# {{{ CPU
CPU()
{
#WRITELOG cpu
 
for THREADS in ${NUM_THREADS}
do
  sysbench --test=cpu --cpu-max-prime=${CPU_MAX_PRIME} --max-requests=${MAX_REQUEST} --num-threads=${THREADS} run >> sysbench_cpu_prime{${CPU_MAX_PRIME}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
done
}
# }}}
 
# {{{ THREADS
THREADS()
{
#WRITELOG thread
 
for THREADS in ${NUM_THREADS}
do
  for LOCKS in ${THREAD_LOCKS}
  do
    sysbench --test=threads --thread-yields=${THREAD_YIELD}  --thread-locks=${LOCKS} --num-threads=${THREADS} --max-requests=${MAX_REQUEST} run >> sysbench_thread_yields{${THREAD_YIELD}}_locks{${LOCKS}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
  done
done
}
# }}}
 
# {{{ MUTEX
MUTEX()
{
#WRITELOG mutex
 
for THREADS in ${NUM_THREADS}
do
  sysbench --test=mutex --mutex-num=${MUTEX_NUM} --mutex-locks=${MUTEX_LOCK} --mutex-loops=${MUTEX_LOOP} --num-threads=${THREADS} --max-requests=${MAX_REQUEST} run >> sysbench_mutex_num{${MUTEX_NUM}}_locks{${MUTEX_LOCK}}_loops{${MUTEX_LOOP}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
done
}
# }}}

# {{{ FILEIO
FILEIO()
{
for THREADS in ${NUM_THREADS}
do
  for BLOCK_SIZE in ${FILEIO_BLKSIZE}
  do
    for FILE_SIZE in ${FILEIO_FILESIZE}
    do
      for IOMODE in ${FILEIO_IOMODE}
      do
        sysbench --test=fileio --init-rng=on --file-num=${FILEIO_FILENUM} --num-threads=${THREADS} --file-total-size=${FILE_SIZE} --max-requests=${MAX_REQUEST} --file-block-size=${BLOCK_SIZE}  --file-test-mode=${IOMODE} prepare
        sysbench --test=fileio --init-rng=on --file-num=${FILEIO_FILENUM} --num-threads=${THREADS} --file-total-size=${FILE_SIZE} --max-requests=${MAX_REQUEST} --file-block-size=${BLOCK_SIZE}  --file-test-mode=${IOMODE} run >> sysbench_mutex_num{${MUTEX_NUM}}_locks{${MUTEX_LOCK}}_loops{${MUTEX_LOOP}}_th{${THREADS}}_req{${MAX_REQUEST}}_{`date +'%Y%m%d%H%M%S'`}.log
      done
    done
  done
done
}
# }}}

# {{{ SLEEP
SLEEP()
{
 sleep $SLEEP_SEC
}
# }}}
 
# {{{ NOTICE
NOTICE()
{
 clear
 
 echo;echo
 echo -n "          "
 echo -e '\E[37;44m' "\033[1m ������sysbench��׼���Թ��߿�ʼִ�� \033[0m"
 echo -e "\033[1m Ĭ�ϵ�,���Խű������ /home/sysbench Ŀ¼�� \033[0m"
 echo -e "\033[1m ��������ݷ������� /home ��,������һ�������� \033[0m"
 echo;echo
}
# }}}
 
# {{{ WRITELOG
WRITELOG()
{
LOG=$WORKDIR/sysbench_$1.log
 
exec 3>&1 4>&2 1>> $LOG 2>&1
}
# }}}
 
# {{{ run benchmark testing
NOTICE
 
#while [ 1 ]
#do
 
CPU
SLEEP
 
THREADS
SLEEP
 
MUTEX
SLEEP
 
MEMORY
SLEEP

FILEIO
SLEEP

OLTP
SLEEP
 
#done
# }}}
 
exit 0