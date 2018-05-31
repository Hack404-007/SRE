# -*- coding: utf-8 -*-
import re
import sys
import socket
import urllib2
 
if len(sys.argv) >= 2:
    url = sys.argv[1]
    url = url.split('/')[2]
    try:
        ip = socket.gethostbyname(url)
        print url+'    >>>    '+ip
        bing = 'http://cn.bing.com/search?&count=100&q=ip:' + ip
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}
        request = urllib2.Request(bing, headers=headers)
        html_doc = urllib2.urlopen(bing).read()
    except Exception:
        print '未获取到数据'
 
    pattern = re.compile('<li class="b_algo".*?>.*?<h2>.*?<a.*?href="(.*?)".*?>(.*?)</a>(.*?)</h2>.*?</li>', re.S)
    ipList = re.findall(pattern, html_doc)
    f = open('IP.txt', 'w')
    for ip in ipList:
        temp = ip[0].split('/')
        temp = temp[0] + '//' + temp[2]
        print '[+]    '+ip[1].decode('utf-8').encode('gbk'), temp
        f.write(str(ip[1] + '     ' + temp) + '\n')
    f.close()
    print str(len(ipList)) + u'条数据[color=#515151]已[/color]写入到IP.txt文件'
else:
    print '命令错误'