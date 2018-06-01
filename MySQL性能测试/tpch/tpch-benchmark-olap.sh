#!/bin/sh
##
## Ö´ÐÐtpch OLAP²âÊÔ
##
## writed by yejr(http://imysql.com), 2012/12/14
##

PATH=$PATH:/usr/local/bin
export PATH

#set -u
#set -x
#set -e

. ~/.bash_profile > /dev/null 2>&1

exec 3>&1 4>&2 1>> tpch-benchmark-olap-`date +'%Y%m%d%H%M%S'`.log 2>&1
I=1
II=3
while [ $I -le $II ]
do
N=1
T=23
while [ $N -lt $T ]
do
  if [ $N -lt 10 ] ; then
    NN='0'$N
  else
    NN=$N
  fi
  echo "query $NN starting"
  /etc/init.d/mysql restart
  time mysql -f tpch < ./queries/tpch_${NN}.sql
  echo "query $NN ended!"
  N=`expr $N + 1`
done

 I=`expr $I + 1`
done