#!/usr/bin/env python
#coding:utf8
#

import re
import os
import urllib
import urllib2

def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html #返回HTML源码

def getIma(html):
    reg = r'"objURL":"(.*?)"' #正则匹配这种图片地址："objURL":"http://img.tupianzj.com/uploads/allimg/160830/9-160S0195408.jpg"
    imgre = re.compile(reg) #使用正则表达式进行编译速度快
#    print imgre

    imglist = re.findall(imgre,html) #正则分组，返回分组后的数据
#    l = len(imglist)
#    print l
    return imglist

def downLoad(urls,path):
    file_name_index = 1 #定义文件名前缀
    for url in urls:
        print "Downloading:",url
        try:
            res = urllib2.Request(url)
            if str(res.status_code)[0] == "4": #如果状态为403 404
                print "未下载成功:", url
                continue
        except Exception as e:
            print "下载成功:", url
        filename = os.path.join(path,str(file_name_index) + ".jpg") #定义下载的文件名
        urllib.urlretrieve(url,filename) #使用urllib.urlretrieve 方法下载图片
        file_name_index += 1 #每次文件名递增1

html = getHtml("http://image.baidu.com/search/index?tn=baiduimage&ps=1&ct=201326592&lm=-1&cl=2&nc=1&ie=utf-8&word=%E8%98%91%E8%8F%87%E5%A4%B4%E8%A1%A8%E6%83%85%E5%8C%85")
#  百度图片的ULR地址
savePath = "./mogutou_image"
downLoad(getIma(html),savePath)

