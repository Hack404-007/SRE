#!/bin/bash
#
# 单进程监控脚本
# 此脚本可行的依赖关系：1、正确的进程启动名称 2、可执行的启动脚本
# Author: YY   
# Version:1.0

# Done not change this follow, except you known what is meaning
CurDir=$(dirname $0)
[ "$CurDir"  == '.' ] && CurDir=$(pwd)
cd $CurDir

# 短信接口调用脚本
SendMsg=/usr/local/monitor/sendsms/sendsms.sh

# 单进程监控列表，如果编辑了额外的监控列表文件，则忽略此处
# 格式：进程名称=进程启动脚本(绝对路径)
Proces="
sendsms=/usr/local/monitor/sendsms/sendsms.sh
"

# 如果监控列表是单独文件，则取消下面的注释
# 文件monitor_list.txt 的内容格式请参考上面变量 Proces
MonitorFile=./monitor_list.txt
if [ ! -f $MonitorFile ];then
    echo "Usage info:"
    echo "请编辑监控列表文件:  $MonitorFile"
    echo "或者设置脚本环境变量: Proces"
    echo "内容格式如下 :$Proces"
    exit
else
	Proces=$(cat $MonitorFile| egrep -v '^#|^$')
fi

# 日志格式打印
FileLog=monitor.log
PrintLog(){
	echo -e "$(date '+%F %T') $1 $2 $3 $4 $5"  >> $FileLog
}

# 清理过期的日志
DAY=3
DelTime=$(/bin/date -d "$DAY days ago" +%F)
/bin/sed -i "/$DelTime/d"  $FileLog


# 进程状态检查,过滤进程的监控脚本
OK=10		# 进程正常
ERR=0		# 进程不存在
function CheckProcess(){
	Process=$1
	PIDS=$(ps -ef|grep ${Process} | grep -v grep |awk '{print $2}')	
	for ID in $PIDS
	do
		File=/proc/${ID}/status
		if [ -f $File ];then
			PName=$(awk '/Name/{print $2}' $File)
			[ "$PName" == "$Process" ] && return $OK
		fi
	done
	return $ERR
}

# 进程监控模块
# 1、进程存在，则打印 CHECK 信息, 表示正常
# 2、进程不存在，则打印 ERROR 信息，表示进程不存在，则尝试自动执行启动脚本拉起进程
# 3、不管新城是否拉起成功，都会发送一条短信给运维人员
function MonitorProcess(){
    for PN in $Proces
    do
	Pro=$(echo $PN | cut -d'=' -f1)
	PStart=$(echo $PN | awk -F'=' '{print $2}')
	CheckProcess $Pro
	RE=$?
	if [ $RE -eq "$OK" ];then
		PrintLog '[CHECK]' "Process Name: $Pro" " Result: OK"
	else 
		PrintLog '[ERROR]' "Process Name: $Pro" " Result:  it's not exist! " " Try to Start it"
		if [ ! -f $PStart ];then
                        PrintLog '[ERROR]' "There is no Start Script:$PStart!" " Please check the file:$MonitorFile"
			$SendMsg "$Pro :no Start Script !!"
                        continue
                fi

		cd $(dirname $PStart)
		sh $PStart    >> $FileLog  2>&1
		CheckProcess $Pro
		RE=$?
		if [ $RE -eq "$OK" ];then
			PrintLog '[INFO]'  "Auto Start Process:$Pro OK !" >> $FileLog
			$SendMsg "$Pro AutoStart OK!"
		else
			PrintLog '[ERROR]' "Auto Start Process:$Pro Fail !"  >> $FileLog
			$SendMsg "$Pro AutoStart Fail !"
		fi
	fi
    done
}

# Begin to monitor script
MonitorProcess




