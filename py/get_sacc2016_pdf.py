#!/usr/bin/env python
#coding:utf8
"""
Run on Linux
"""
import os
import re, urllib


#创建目录
_dir = 'SACC2016'
if not os.path.isdir(_dir):
    os.mkdir(_dir)

def geturlsrc(url):
    src = urllib.urlopen(url)
    html = src.read()
    return html

def getdsturl(html):
    #正则匹配各主(专)场URL
    urlreg = r'<li><a href="(http:.*)">'
    urlre =  re.compile(urlreg)
    urls = re.findall(urlre,html)

    for url in urls:
        html=geturlsrc(url)
        #正则匹配pdf文件URL
        pdfreg = r'<li><a href="(http:.*－)(.*).pdf" target="_blank">• (.*)</a><a href'
        pdfre = re.compile(pdfreg)
        pdfs = re.findall(pdfre, html)

        #下载
        for i in pdfs:
            url = i[0]+i[1]+".pdf"
            _filename = i[1]+"-"+i[2]+".pdf"
            filename = re.sub('/', '_', _filename)
            print url, filename
            urllib.urlretrieve(url, _dir + '/' + filename)


url=geturlsrc('http://sacc.it168.com/PPT2016/')
getdsturl(url)
