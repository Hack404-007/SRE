#!/bin/bash
#
# Name:monitor_crmu.sh
# Description: monitor crmu program
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-06-14 10:28:19
# Usage: sh monitor_crmu.sh

program_Dir=/opt/paas/crmu
bin_Birary=${program_Dir}/bin/crmu
script_Exec=${program_Dir}/start.sh
msg_Script=/usr/local/monitor/sendsms/sendsms.sh
log_File=/usr/local/monitor/crmu/crmu.log
check_crmu()
{
	pro_Pid=$(ps -ef  | grep "${bin_Birary}" | grep -v grep | wc -l)
	if [ ${pro_Pid} -eq 0 ]; then
		echo "The proGram is Stoped" >> ${log_File}
		cd ${program_Dir}
		./start.sh > /dev/null
		if test $? -eq 0; then
			${msg_Script} "crmu is restrt Sucessed." >> ${log_File}
		fi
	else
		echo "The proGram is Running." >> ${log_File}
	fi
}

check_crmu
exit 1
