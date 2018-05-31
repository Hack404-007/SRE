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
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT                                                                
iptables -A INPUT -p tcp --dport 18735 -j ACCEPT
iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A INPUT -p udp --dport 111 -j ACCEPT
iptables -A INPUT -p tcp --dport 2049 -j ACCEPT
iptables -A INPUT -p udp --dport 2049 -j ACCEPT
iptables -A INPUT -p tcp --dport 10001:10004 -j ACCEPT
iptables -A INPUT -p udp --dport 10001:10004 -j ACCEPT                                                               
