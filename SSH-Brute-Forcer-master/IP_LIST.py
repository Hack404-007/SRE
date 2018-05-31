#coding:utf8

from IPy import IP

ip_Range=raw_input("Please input your ip range:")

ip = IP(ip_Range)

for x in ip:
    print x