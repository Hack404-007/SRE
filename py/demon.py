#coding:gbk
'''
import urllib2
request = urllib2.Request("http://www.ucpaas.com")
response = urllib2.urlopen(request)
print response.read()
'''

'''
POST
import  urllib
import  urllib2


vlaues = {"userid":"mengtao10@163.com","password":"1a2s3d4f5g"}
data = urllib.urlencode(vlaues)

url = "http://www.ucpaas.com/user/login"
request = urllib2.Request(url,data)
response = urllib2.urlopen(request)

print response.read()
'''
'''
import urllib
import urllib2

def flush_Config():
        request = urllib2.Request("http://sendsms.ucpaas.com:8194/alarm/sms/flushConfig")
        response = urllib2.urlopen(request)
        url_code = int(response.getcode())
        if url_code == 200:
                return "SUCESSED."
        else:
                return "FAILED."
print flush_Config()
'''

