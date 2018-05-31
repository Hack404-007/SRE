#!/bin/bash
# Name:mysql_full.sh
# Description: MySQL Full Backup For MySQLdump
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-01-20 22:53:14
# Usage: mysql_full.sh /You Can Run it On Slave at 1:00

userName=root
PORT=3306
PASS=xxx
Host=localhost
backup_Dir=/data/backup
data_Dir=`date +%Y-%m-%d`
mysql_Exec=/usr/local/mysql/bin/mysql
mysql_Dump=/usr/local/mysql/bin/mysqldump
mysql_Data=/app/mydata
dbNames=`${mysql_Exec} -h${Host} -u${userName} -p${PASS} -e  "SHOW DATABASES;" | grep -v "Database"`
store_Dir=${backup_Dir}/${data_Dir}
log_File=${store_Dir}/mysql_backup.log
[ -d ${store_Dir} ] || mkdir -pv ${store_Dir}

for db in ${dbNames}; do
	${mysql_Dump} -h${Host} -u${userName} -p${PASS} --default-character-set=utf8 -q --lock-all-tables --flush-logs -E -R --triggers -B ${db} | gzip > ${store_Dir}/${db}.sql.gz
	if [ $? -eq 0 ]; then
		echo "${db} Backup is Sucessed.." >> ${log_File}
	else
		echo "${db} Backup is Failed.." >> ${log_File}

	fi
done

bin_Log=$(tail -n 1 ${mysql_Data}/mysql-bin.index | sed 's/.\///')
${mysql_Exec} -h${Host} -u${userName} -p${PASS} -e -A "PRUGE BINARY LOGS TO ${bin_Log};"
