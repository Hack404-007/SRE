#!/bin/sh
##
## ִ��IOZONE FILEIO��׼����
##
## writed by yejr(http://imysql.com), 2012/12/14
##

PATH=$PATH:/usr/local/bin
export PATH

#set -u
#set -x
#set -e

# {{{ ���ֲ���
WORKDIR=/home/iozone
cd ${WORKDIR}

exec 3>&1 4>&2 1>> iozone_benchmark_fileio-`date +'%Y%m%d%H%M%S'`.log 2>&1

SLEEP_SEC=120
#�ļ����С��4 ~ 64k
FILEIO_BLK_SIZE="4k 8k 16k 32k 64k"
#ÿ���ļ���С��1 ~ 16G
FILEIO_TOTAL_SIZE="1024M 2048M 4096M 8192M 16384M"
#���������飺1 ~ 16
NUM_THREADS="1 2 4 8 16"
#�����豸����6SAS_RAID10��Ϊ6��SAS�����RAID 1+0��2SSD_RAID1��Ϊ2��SSD�����RAID 1
#DEVICE="6SAS_RAID10"
DEVICE="2SSD_RAID1"

# }}}

# {{{ MUTEX
FILEIO()
{
for FILEIO_SIZE in ${FILEIO_TOTAL_SIZE}
do
  for FILEIO_BLK in ${FILEIO_BLK_SIZE}
  do
    for THREADS in ${NUM_THREADS}
    do
      iozone -R -E -s ${FILEIO_SIZE} -l ${THREADS} -r ${FILEIO_BLK} >> iozone_{${DEVICE}}_R_E_s_{${FILEIO_SIZE}}_l_{${THREADS}}_r_{${FILEIO_BLK}}_{`date +'%Y%m%d%H%M%S'`}.log
    done
  done
done
}
# }}}

#while [ 1 ]
#do

FILEIO
SLEEP

#done