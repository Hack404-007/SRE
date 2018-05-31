#!/bin/bash
export PATH='$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin'
#该脚本分析nginx日志并根据日志信息提取计算下面指标：
#1. 平均每分钟的访问次数
#2. 5分钟内的平均耗时
#3. 5分钟内的最大耗时
#4. 5分钟内平均每分钟的访问独立IP数
#5.
# date +%d/%b/%Y:%H:%M:%S
f_set_global_info()
{
  logdir="${curdir}/log"
  if [ ! -d ${logdir} ]; then
    mkdir -p ${logdir}
  fi
  tmpdir="${curdir}/tmp"
  if [ ! -d ${tmpdir} ]; then
    mkdir -p ${tmpdir}
  fi

  analyze_binfile=${curdir}/bin/loganaly.py
  if [ ! -f ${analyze_binfile} ]; then
    echo "分析日志的关键文件${analyze_binfile}不存在,无法执行.退出"
    exit 1
  fi

  ##配置基全局信息本
  ServerActive=10.10.16.198
  ServerReport=/usr/local/zabbix/bin/zabbix_sender
  LOG_FILE=${logdir}/mon_api_nginx_analyze_report_agentd.log
  LogFileSize=10455040
  #需要替换成对应机器的IP，即上报和配置zabbix对应的IP
  ##获取IP
  ethnum=`/sbin/ifconfig|grep eth|wc -l`
  if [ ${ethnum} -gt 1 ]; then
    ip_inner=`/sbin/ifconfig eth1 2>/dev/null|grep 10.10.130 |grep "inet addr:"|awk -F ":" '{ print $2 }'|awk '{ print $1 }'`
  else
    ethname=`/sbin/ifconfig|grep eth|awk '{print $1}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
    ip_inner=`/sbin/ifconfig ${ethname} 2>/dev/null |grep "inet addr:"|awk -F ":" '{ print $2 }'|awk '{ print $1 }'`
  fi
  ZABBIX_NAME=${ip_inner}
  ZABBIX_NAME=10.10.130.119
  echo "LOCAL IP: ${ZABBIX_NAME}"
  DATA_FILE=${tmpdir}/result_monagent_${uuid}
  if [ -s ${DATA_FILE} ]; then
    > ${DATA_FILE}
  fi

  if [ -f ${LOG_FILE} ]; then
    logfilesize=`ls -l ${LOG_FILE}|awk '{print $5}'`
    if [ ${logfilesize} -gt ${LogFileSize} ]; then
      >${LOG_FILE}
    fi
  fi

}

f_get_deal_file()
{
 local dealfilename=$1
 n1=`egrep -n  "${start_date}" ${dealfilename}| head -1| cut -d ':' -f 1`
 n2=`egrep -n  "${end_date}"   ${dealfilename}| tail -1| cut -d ':' -f 1`

 if [ "xx${n1}" == "xx" ]; then 
   n1=0
 fi

 if [ "xx${n2}" == "xx" ]; then 
   n2=0
 fi
 ## 无提取数据，本次不做处理
 if [ ${n1} -eq 0 -o ${n2} -eq 0 ]; then
   echo "${dealfilename}无需要处理的数据,忽略. `date +%Y%m%d" "%X`############################"  >> $LOG_FILE 
   echo "${dealfilename}无需要处理的数据,忽略. `date +%Y%m%d" "%X`############################"
 else
   sed -n "${n1},${n2}p" ${dealfilename}  >> ${tmp_nginxfile}
 fi
}

 ########################### main ##############################3
 #输入nginx文件名
 #注意：nginx的日志格式必须符合下面条件，否则，可能分析会有问题.
 # log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
 #                     '$status $body_bytes_sent "$http_referer" '
 #                     '"$http_user_agent" "$http_x_forwarded_for" "$request_time" "$host"';
 echo "############START ... `date +%Y%m%d" "%X`############################"
 export SCRIPT_NAME="$0"
 ##要处理的日志文件列表
 #nginxlogfile=/data/weblog/api.ucpaas.com.access.log
 nginxlogfile=/usr/local/nginx/logs/api.ucpaas.com.access.log
 
 curdir=`dirname $0`
 if [ $curdir = '.' ];then
  curdir=`pwd`
 fi
UUID=$$
##初始环境设置
f_set_global_info
echo "############START ... `date +%Y%m%d" "%X`############################"  >> $LOG_FILE

##根据时间把要提取的数据先独立提取出来，减少运算量和负载 
splittime=5

#end_date="`date +%d/%b/%Y:%H:%M`"
end_date="`date -d '1 minutes ago' +%d/%b/%Y:%H:%M`"
start_date="`date -d \"$[splittime+1] minutes ago\" +%d/%b/%Y:%H:%M`"
echo "##START_DATE=$start_date  END_DATE=$end_date"
tmp_nginxfile=${tmpdir}/analysis_nginx_curr_${UUID}.log
format_nginxfile=${tmpdir}/analysis_nginx_formated_${UUID}.log
>${tmp_nginxfile}
#生成要分析的日志
f_get_deal_file ${nginxlogfile}
####################### nginx 日志分割   请求量过大，每2小时分割一次 ####################################
# timestr=`date +%M`
# hourstr=`date +%H`
# modhour=`echo "${hourstr}%2"|bc`
# echo "#################`date`##### ${hourstr}   ${modhour}#########TIMESTR: $timestr"
# if [ ${modhour} -eq 0 -a ${timestr} -le '04' ]; then
#   echo "`date` nginx log start split..."
#   /bin/sh /usr/local/nginx/sbin/nginx_log_split.sh >/usr/local/nginx/sbin/nginx_log_split.log
# fi
###################### nginx 日志分割  ####################################

#格式化nginx日志，以便后面做分析提取数据.
${analyze_binfile} ${tmp_nginxfile} >${format_nginxfile}
##判断文件是否有记录，如有处理，如无，忽略
nginxfilenum=`cat ${format_nginxfile}|wc -l`
if [ ${nginxfilenum} -gt 0 ]; then
  #格式化后的数据类似如下:
  #118.180.8.68|2013-03-08 13:36:58|200|70|0.700
  visitsum=`cat ${format_nginxfile}|wc -l`
  #1.每分钟内的请求次数{Cached})*100
  avgmin_vistnum=`echo "scale=2; ${visitsum}/${splittime}"|bc`
  ##2. 5分钟内的访问独立IP数
  ip_5min_num=`cat ${format_nginxfile}|awk -F '|' '{print $1}'|sort|uniq|wc -l`
  ##3.平均耗时
  alltime=`awk -F '|' 'BEGIN{sum=0}{sum+=$5}END{print sum}' ${format_nginxfile}`
  echo  $visitsum
  #avg_visitime=$(("scale=4; ${alltime}*1000/${visitsum}"|bc))
  avg_visitime=`awk "BEGIN{printf(\"%2.4f\n\",${alltime}*1000/${visitsum})}"`
  echo alltime=${alltime}  
  echo avg_visitime=${avg_visitime}
echo +++++++++++++++++++++
  #求平均值
  #cat nginx_info.txt |awk -F '|' '{print $5}'|awk '{sum+=$1} END {print "Average = ", sum/NR}'
  ##4.5分钟内最大请求时间
  #cat nginx_info.txt |awk -F '|' '{print $5}'|awk 'BEGIN {max = 0} {if ($1>max) max=$1 fi} END {print "Max=", max}'
  max_visitime=`cat ${format_nginxfile} |awk -F '|' '{print $5}'|awk 'BEGIN {max = 0} {if ($1+0 >max+0) max=$1 fi} END {print max}'`
  ##5.访问请求返回200占比例  
  vist200num=`cat ${format_nginxfile}|awk -F '|' 'BEGIN{count=0}{if ($3 == "200"){count++;} } END {print count}'`
  sucessrate=`echo "scale=3; (${vist200num}*100)/${visitsum}"|bc`
  #**********************************************2013-10-09***************************************# 
  avgreal_vistnum=`echo "scale=2; ${vist200num}/${splittime}"|bc`  
  ##6.访问请求返回200平均耗时
  #awk -F '|'  'BEGIN{sum=0}{if($3 != "429"){sum+=$5}}END{print sum}' analysis_nginx_formated_15802.log 
  sumrealtime=`awk -F '|' 'BEGIN{sum=0}{sum+=$5}END{printf "%f",sum}' ${format_nginxfile}`
  #avg_realtime=`echo "scale=4; ${sumrealtime}/${vist200num}"|bc`  
  avg_realtime=`awk "BEGIN{printf(\"%2.2f\n\",${sumrealtime}*1000/${vist200num})}"`  
  echo "sumrealtime= ${sumrealtime}  avg_realtime=${avg_realtime}"
  
  #**********************************************2013-10-09*******************************************# 
  ##生成指标文件 
  str_requestmax_ip="`cat ${format_nginxfile}|awk -F '|' '{print $1}'|sort |uniq -c|sort -n|tail -1`"
  maxrequestsum=`echo ${str_requestmax_ip}|awk '{print $1}'`
  maxreq_avgnum=`echo "scale=2; ${maxrequestsum}/${splittime}"|bc`
  maxreq_ip=`echo ${str_requestmax_ip}|awk '{print $2}'`  
  otherstr="`cat ${format_nginxfile} |awk -F '|' '{print $3}'|sort|uniq -c |sort -n|xargs`"
  maxreqinfo="${maxreq_ip}在${splittime}min内请求${maxrequestsum},${maxreq_avgnum}/min;返回值统计:${otherstr}"
##每分钟平均请求次数
##独立IP数
##平均耗时
##成功率
##返回200的平均耗时
#最大请求时间
echo "$ZABBIX_NAME api.avgmin.visitnum ${avgmin_vistnum}
$ZABBIX_NAME api.visitip.5num ${ip_5min_num}
$ZABBIX_NAME api.avgvisit.time ${avg_visitime}
$ZABBIX_NAME api.visit.success ${sucessrate}
$ZABBIX_NAME api.maxreq.oneipnum ${maxreq_avgnum}
$ZABBIX_NAME api.maxreq.ipinfo ${maxreqinfo}
$ZABBIX_NAME api.avgmin.realvisit ${avgreal_vistnum}
$ZABBIX_NAME api.avgvisit.realtime ${avg_realtime}
$ZABBIX_NAME api.max5min.visittime ${max_visitime}">>${DATA_FILE}
else
  echo "######################`date +%Y%m%d" "%X`##本次分析的日志中无数据，上报为0.################" >> $LOG_FILE
  echo "######################`date +%Y%m%d" "%X`##本次分析的日志中无数据，上报为0.################"
  echo "$ZABBIX_NAME api.avgmin.visitnum 0
$ZABBIX_NAME api.visitip.5num 0
$ZABBIX_NAME api.avgvisit.time 0
$ZABBIX_NAME api.visit.success 0
$ZABBIX_NAME api.maxreq.oneipnum 0
$ZABBIX_NAME api.maxreq.ipinfo 0
$ZABBIX_NAME api.avgmin.realvisit 0
$ZABBIX_NAME api.avgvisit.realtime 0
$ZABBIX_NAME api.max5min.visittime 0">>${DATA_FILE}

fi

##发送上报
echo "############`date +%Y%m%d" "%X`############################"  >> $LOG_FILE
cat ${DATA_FILE} >> $LOG_FILE

if [ -s $DATA_FILE ]; then
 ${ServerReport} -vv -z ${ServerActive} -i $DATA_FILE 2>>$LOG_FILE 1>>$LOG_FILE
 echo  -e "Successfully executed $COMMAND_LINE" >>$LOG_FILE
else
 echo "Error in executing $COMMAND_LINE" >> $LOG_FILE
fi
rm -f $DATA_FILE
echo "######################`date +%Y%m%d" "%X`##END################" >> $LOG_FILE
echo "######################`date +%Y%m%d" "%X`##END################"

rm -f ${tmp_nginxfile}
rm -f ${format_nginxfile}
echo "####`date` 本次处理完毕####"
