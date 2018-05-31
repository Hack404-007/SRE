#!/bin/bash
# Author by: Tore.Meng
# Time: 2018.03.30
# descript: iptables rules for centos 6/7.x

# define command path and name 
IPT="/sbin/iptables"
SPAMLIST="blockedip"
SPAMDROPMSG="BLOCKED IP DROP"

# whether system centos 7.x or centos 6.x
if grep -E "7.[1-5]." /etc/redhat-release > /dev/null 2>&1; then
	systemctl stop firewalld.service > /dev/null
	systemctl disable firewalld.service  > /dev/null
	yum install iptables-services -y  > /dev/null
fi

# empty iptables rules
echo "Starting IPv4 Wall..."
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X

# load kernel mode for iptables && logfile in /var/log/message
modprobe ip_conntrack

# define iptabels blacklist file
[ -f /root/scripts/blocked.ips.txt ] && BADIPS=$(egrep -v -E "^#|^$" /root/scripts/blocked.ips.txt)

# define LAN && WAN interface
PUB_IF="em1"
PUB_LAN="em2"

# unlimited 
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

$IPT -A INPUT -i ${PUB_LAN} -j ACCEPT
$IPT -A OUTPUT -o ${PUB_LAN} -j ACCEPT

# DROP all incomming traffic
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

if [ -f /root/scripts/blocked.ips.txt ]; then
# create a new iptables list
	$IPT -N $SPAMLIST
 
	for ipblock in $BADIPS; do
   		$IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
   		$IPT -A $SPAMLIST -s $ipblock -j DROP
	done
 
	$IPT -I INPUT -j $SPAMLIST
	$IPT -I OUTPUT -j $SPAMLIST
	$IPT -I FORWARD -j $SPAMLIST
fi

# Block sync
$IPT -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW  -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Drop Sync"
$IPT -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP

# Block Fragments
$IPT -A INPUT -i ${PUB_IF} -f  -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fragments Packets"
$IPT -A INPUT -i ${PUB_IF} -f -j DROP

# Block bad stuff
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "NULL Packets"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -j DROP # NULL packets

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "XMAS Packets"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP #XMAS

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fin Packets Scan"
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags FIN,ACK FIN -j DROP # FIN packet scans

$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Allow full outgoing connection but no incomming stuff
$IPT -A INPUT -i ${PUB_IF}  -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF}  -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Allow ssh 
$IPT -I INPUT -p tcp --destination-port 60086 -j ACCEPT
$IPT -I INPUT -p tcp --destination-port 22 -j ACCEPT

# Allow zabbix
$IPT -A INPUT -p tcp --destination-port 10050 -j ACCEPT
$IPT -A INPUT -p udp --destination-port 10050 -j ACCEPT

# Allow VNC Range Port
$IPT -A INPUT -s 202.105.136.110/32 -p tcp --dport 5900:5920 -j ACCEPT

# allow incomming ICMP ping pong stuff
$IPT -A INPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow port 53 tcp/udp (DNS Server)
$IPT -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p udp --sport 53 -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPT -A INPUT -p tcp --destination-port 53 -m state --state NEW,ESTABLISHED,RELATED  -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 53 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Open port 80
$IPT -A INPUT -p tcp --destination-port 80 -j ACCEPT
##### Add your rules below ######

##### END your rules ############

# Do not log smb/windows sharing packets - too much logging
$IPT -A INPUT -p tcp -i eth0 --dport 137:139 -j REJECT
$IPT -A INPUT -p udp -i eth0 --dport 137:139 -j REJECT

# log everything else and drop
$IPT -A INPUT -j LOG
$IPT -A FORWARD -j LOG
$IPT -A INPUT -j DROP

exit 0
