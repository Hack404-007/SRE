#!/usr/bin/python
#coding:utf8
import json
import os
import sys
import socket
import urllib2

if len(sys.argv) < 2:
        print "Usage: %s domainname or ip address" % sys.argv[0]
        sys.exit()

ipadd=sys.argv[1]
osname=socket.gethostname()
st1='mtr -n -i 0.3 -c 10 -r -w'+' '+ ipadd+' '+'> /tmp/ipres'

def GetIp(o):
    respone=urllib2.urlopen('http://ip.taobao.com/service/getIpInfo.php?ip='+o)
    t=respone.read()
    data=json.loads(t)
    return data['data']['country'],data['data']['city'],data['data']['isp']

os.system(st1)
fp=open('/tmp/ipres')
print '\tHOST:'+ osname +' \tLoss%\tSnt\tLast\tAvg\tBest\tWrst\tStDev\tISP'
for i in fp.readlines()[1:]:
    t=i.strip()
    for p in i.strip().split()[1:2]:
        if p == '???':
            x='Forbid ICMP detect '
            print t + '    ' + x
        elif p == '`|--':
            del p
        elif p == '|--':
            del p
        else:
            z,x,y=GetIp(p)
            if z == 'IANA':
                z='internet IP'
            print t + '    ' + z + x + y
fp.close()
os.remove('/tmp/ipres')
