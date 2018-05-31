#!/bin/bash
#
User=root
Pass='6ISbBx3C0mx'
Host=localhost
mysql_Exec=/usr/local/mysql/bin/mysql
${mysql_Exec} -h${Host} -u${User}  -e "grant all privileges on *.* to root@'127.0.0.1' identified by '${Pass}' with grant option;"
${mysql_Exec} -h${Host} -u${User}  -e "grant all privileges on *.* to root@'localhost' identified by '${Pass}'with grant option;"
${mysql_Exec} -h${Host} -u${User} -p${Pass} -e "delete from mysql.user where Password='';"
${mysql_Exec} -h${Host} -u${User} -p${Pass} -e "delete from mysql.db where User='';"
${mysql_Exec} -h${Host} -u${User} -p${Pass} -e "drop database test;"
${mysql_Exec} -h${Host} -u${User} -p${Pass} -e "reset master;"
