#!/bin/bash

/etc/init.d/iptables start
iptables -F                                                                                                  
iptables -t nat -F                                                                                           
iptables -t mangle -F                                                                                        
iptables -t raw -F                                                                                           
iptables -Z                                                                                                  
iptables -t nat -Z                                                                                           
iptables -t mangle -Z                                                                                       
iptables -t raw -Z                                                                                          
iptables -X                                                                                                  
iptables -t nat -X                                                                                          
iptables -t mangle -X                                                                                        
iptables -t raw -X                                                                                           
iptables -P INPUT DROP                                                                                     
iptables -P FORWARD ACCEPT                                                                                   
iptables -P OUTPUT ACCEPT                                                                                    
iptables -t nat -P PREROUTING ACCEPT                                                                         
iptables -t nat -P POSTROUTING ACCEPT        
iptables -A INPUT -p icmp  -j ACCEPT
iptables -A OUTPUT -p icmp   -j ACCEPT                                                                
iptables -A INPUT -i lo -j ACCEPT                                                                            
iptables -A INPUT -i eth1 -j ACCEPT                                                                            
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT                                             
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT                                           
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT                                                              
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT                                                              
iptables -A FORWARD -p udp --dport 53 -j ACCEPT                                                              
iptables -A INPUT -p tcp --dport 80 -j ACCEPT                                                              
iptables -A INPUT -p tcp --dport 60086 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 60088 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 8002 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 8889 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 25151 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 443 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 3690 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 3389 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 69 -j ACCEPT                                                                
iptables -A INPUT -p udp --dport 69 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 25 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 110 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 10050 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 10051 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 389 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 636 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 9000 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 18081 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 18082 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 18083 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 18091 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 28091 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 38091 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 8083 -j ACCEPT                                                                
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 1.1.88.101
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 9000 -j DNAT --to-destination 10.10.201.17:9000
# liulu dudo
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 18081 -j DNAT --to-destination 10.10.201.31:18081
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 14010 -j DNAT --to-destination 10.10.201.31:4010
# 
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 18082 -j DNAT --to-destination 10.10.201.31:18082
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 18083 -j DNAT --to-destination 10.10.201.31:18083
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8080 -j DNAT --to-destination 10.10.201.15:18080

#ott丢包监控

iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8084 -j DNAT --to-destination 10.10.201.41:8080

#yaojianwei huangbotao 自动化测试
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13390 -j DNAT --to-destination 10.10.201.46:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13391 -j DNAT --to-destination 10.10.201.47:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13392 -j DNAT --to-destination 10.10.201.48:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13393 -j DNAT --to-destination 10.10.201.49:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13394 -j DNAT --to-destination 10.10.201.50:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13395 -j DNAT --to-destination 10.10.201.51:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13396 -j DNAT --to-destination 10.10.201.52:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13397 -j DNAT --to-destination 10.10.201.53:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13398 -j DNAT --to-destination 10.10.201.54:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13399 -j DNAT --to-destination 10.10.201.55:3389

iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8933 -j DNAT --to-destination 10.10.202.57:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13400 -j DNAT --to-destination 10.10.201.162:3389


iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8082 -j DNAT --to-destination 10.10.201.133:8082
#
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 13389 -j DNAT --to-destination 10.10.201.82:3389
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15901 -j DNAT --to-destination 10.10.203.201:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15902 -j DNAT --to-destination 10.10.203.202:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15903 -j DNAT --to-destination 10.10.203.203:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15904 -j DNAT --to-destination 10.10.203.204:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15905 -j DNAT --to-destination 10.10.203.205:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15906 -j DNAT --to-destination 10.10.203.206:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15907 -j DNAT --to-destination 10.10.203.207:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15908 -j DNAT --to-destination 10.10.203.208:5900
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 18091 -j DNAT --to-destination 10.10.201.115:8091
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 28091 -j DNAT --to-destination 10.10.201.116:8091
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 38091 -j DNAT --to-destination 10.10.201.126:8091
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 15672 -j DNAT --to-destination 10.10.201.118:15672
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 25672 -j DNAT --to-destination 10.10.201.128:15672

iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 9001  -j DNAT --to-destination 10.10.201.117:9001
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8083  -j DNAT --to-destination 10.10.201.30:8083
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 8081  -j DNAT --to-destination 10.10.201.152:8080
iptables -t nat -A PREROUTING -i eth0 -d 1.1.88.101 -p tcp --dport 38080  -j DNAT --to-destination 10.10.201.122:38080


/etc/init.d/iptables save 
