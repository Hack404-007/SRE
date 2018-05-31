#!/usr/bin/python2.6
# vim: set expandtab tabstop=4 shiftwidth=4 autoindent smartindent:
from core import Pygtail
import os
import sys
import apachelog
import time

inputfn = sys.argv[1]
#log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                      '$status $body_bytes_sent "$http_referer" '
#                      '"$http_user_agent" "$http_x_forwarded_for" "$request_time" "$host" "${app_key}-${receiver_type}" "$versionno"' ;

#log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                      '$status $body_bytes_sent "$http_referer" '
#                      '"$http_user_agent" "$http_x_forwarded_for" "$upstream_addr"'

#format = r'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-FORWARDED-FOR}i\" %T %U'
format = r'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-FORWARDED-FOR}i\" %T'
#format = r'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" "%a" %T'
format2 = r'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
format3 = r'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %a %T %U'
#%h %t %>s %b %T
p = apachelog.parser(format)
p2 = apachelog.parser(format2)
p3 = apachelog.parser(format3)

if False == os.path.exists(inputfn):
    print 'input file not exists'
    sys.exit(0)  

f = open(inputfn, 'r')
while True:
    line = f.readline()
    if not line:
        break
    try:
        d = p.parse(line)
        has_rqstime = 1
    except:
        try:
            d = p2.parse(line)
            has_rqstime = 0
        except:
            try:
                d = p3.parse(line)
                has_rqstime = 1
            except:
                #print "Parse error:",line
                continue
#    print "ddd[%s]" % str(d)

    url = d['%r'].split()
    if len(url) != 3:
        continue
    url = url[1]
    is_suc = 0
    

    client_ip = d['%h'].strip()    
    #realip = d['%a'].strip('"').strip()
    #realip = d['%{X-FORWARDED-FOR}i'].strip()
    #print realipi
    if d.has_key('%{X-FORWARDED-FOR}i') == True:
        realip = d['%{X-FORWARDED-FOR}i'].strip()
    else:
        realip = ''

    rqst_timestamp = d['%t']
    rqst_timestamp = rqst_timestamp.strip('[')
    (rqst_timestamp, tmp) = rqst_timestamp.split()
    t = time.strptime(rqst_timestamp, '%d/%b/%Y:%H:%M:%S')
    rqst_timestamp = "%s" % (time.strftime("%Y-%m-%d %H:%M:%S", t))
  
    status = d['%>s']
    
    size = d['%b']

    #urltime = d['%T'].replace("\"",'')
    temp_urltime = d['%U'].split(' ')
    if len(temp_urltime) > 1:
        urltime = temp_urltime[1].replace("\"",'')
    else:
        urltime = 0
    
    reallen = len(realip)
    if reallen > 8 :
      tmprealip = realip.split(',')
      finalip = tmprealip[0]
    else:
      finalip = client_ip 
   

    output_str =  "%s|%s|%s|%s|%s" % ( finalip, rqst_timestamp, status,size,urltime)
    
    print output_str

f.close()
