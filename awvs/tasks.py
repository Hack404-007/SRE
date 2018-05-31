#-*- coding:utf-8 -*-
import urllib2
import ssl
import json

#localhost:3443全部替换为awvs所在的服务器及端口
username='sre@ucpaas.com'
#账号邮箱
pw='b46a586d8edb1ed62e0adc80e754fef87fb23151b6124a3ad57696fa0560db23'
#sha256加密后的密码，通过burp抓包可获取,也可以使用(http://tool.oschina.net/encrypt?type=2)把密码进行加密之后填入，请区分大小写、中英文字符。
#以上内容为配置内容，然后把要添加的url列表保存成testawvs.txt文件，放在该脚本下运行该脚本。
ssl._create_default_https_context = ssl._create_unverified_context
url_login="https://172.16.1.144:3443/api/v1/me/login"
send_headers_login={
'Host': '172.16.1.144:3443',
'Accept': 'application/json, text/plain, */*',
'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
'Accept-Encoding': 'gzip, deflate, br',
'Content-Type': 'application/json;charset=utf-8'
}

data_login='{"email":"'+username+'","password":"'+pw+'","remember_me":false}'

req_login = urllib2.Request(url_login,headers=send_headers_login)
response_login = urllib2.urlopen(req_login,data_login)
xauth = response_login.headers['X-Auth']
COOOOOOOOkie = response_login.headers['Set-Cookie']
print "当前验证信息如下\r\n cookie : %r  \r\n X-Auth : %r  "%(COOOOOOOOkie,xauth)
send_headers2={
'Host':'172.16.1.144:3443',
'Accept': 'application/json, text/plain, */*',
'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
'Content-Type':'application/json;charset=utf-8',
'X-Auth':xauth,
'Cookie':COOOOOOOOkie
}
#以上代码实现登录（获取cookie）和校验值
def add_exec_scan():
	url="https://172.16.1.144:3443/api/v1/targets"
	try:
		urllist=open('testawvs.txt','r')#这是要添加的url列表
		formaturl=urllist.readlines()
		for i in formaturl:
			target_url='http://'+i.strip()
			data='{"description":"222","address":"'+target_url+'","criticality":"10"}'
			#data = urllib.urlencode(data)由于使用json格式所以不用添加
			req = urllib2.Request(url,headers=send_headers2)
			response = urllib2.urlopen(req,data)
			jo=json.loads(response.read())
			target_id=jo['target_id']#获取添加后的任务ID
			#print target_id
			#以上代码实现批量添加

			url_scan="https://172.16.1.144:3443/api/v1/scans"
			headers_scan={
				'Host': '172.16.1.144:3443',
				'Accept': 'application/json, text/plain, */*',
				'Accept-Language': 'zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3',
				'Accept-Encoding': 'gzip, deflate, br',
				'Content-Type': 'application/json;charset=utf-8',
				'X-Auth':xauth,
				'Cookie':COOOOOOOOkie,
			}			
			data_scan='{"target_id":'+'\"'+target_id+'\"'+',"profile_id":"11111111-1111-1111-1111-111111111111","schedule":{"disable":false,"start_date":null,"time_sensitive":false},"ui_session_id":"66666666666666666666666666666666"}'
			req_scan=urllib2.Request(url_scan,headers=headers_scan)
			response_scan=urllib2.urlopen(req_scan,data_scan)
			print response_scan.read()+"添加成功！"
			#以上代码实现批量加入扫描
			urllist.close()
	except Exception,e:
		print e

def count():
	url_count="https://172.16.1.144:3443/api/v1/notifications/count"
	req_count=urllib2.Request(url_count,headers=send_headers2)
	response_count=urllib2.urlopen(req_count)
	print "当前存在%r个通知！" % json.loads(response_count.read())['count']
	print "-" * 50
	print "已存在以下任务"
	url_info="https://172.16.1.144:3443/api/v1/scans"
	req_info=urllib2.Request(url_info,headers=send_headers2)
	response_info=urllib2.urlopen(req_info)
	all_info = json.loads(response_info.read())
	num = 0
	for website in all_info.get("scans"):
		num+=1
		print website.get("target").get("address")+" \r\n target_id:"+website.get("scan_id")
		print "共 %r个扫描任务" % num
#count()
#scan、target、notification！
def del_scan():
	url_info="https://172.16.1.144:3443/api/v1/scans"
	req_info=urllib2.Request(url_info,headers=send_headers2)
	response_info=urllib2.urlopen(req_info)
	all_info = json.loads(response_info.read())
	counter = 0
	for website in all_info.get("scans"):
#if (website.get("target").get("description"))== "222":
		url_scan_del="https://172.16.1.144:3443/api/v1/scans/"+str(website.get("scan_id"))
		req_del = urllib2.Request(url_scan_del,headers=send_headers2)
		req_del.get_method =lambda: 'DELETE'
		response_del = urllib2.urlopen(req_del)
		counter = counter+1
		print "已经删除第%r个!" %  counter
#del_scan()#通过描述判断是否使用扫描器添加扫描器添加的时候设置description=“222”
def del_targets():
	url_info="https://172.16.1.144:3443/api/v1/targets"
	req_info=urllib2.Request(url_info,headers=send_headers2)
	response_info=urllib2.urlopen(req_info)
	all_info = json.loads(response_info.read())
	for website in all_info.get("targets"):
		if (website.get("description"))== "222":
			url_scan_del="https://172.16.1.144:3443/api/v1/targets/"+str(website.get("target_id"))
			req_del = urllib2.Request(url_scan_del,headers=send_headers2)
			req_del.get_method =lambda: 'DELETE'
			response_del = urllib2.urlopen(req_del)
			print "ok!"
#del_targets()
if __name__== "__main__":
	print "*" * 20
	count()
	print "1、使用testawvs.txt添加扫描任务并执行请输入1，然后回车\r\n2、删除所有使用该脚本添加的任务请输入2，然后回车\r\n3、删除所有任务请输入3，然后回车\r\n4、查看已存在任务请输入4，然后回车\r\n"
	choice = raw_input(">")
#print type(choice)

	if choice =="1":
		add_exec_scan()
		count()
	elif  choice =="2":
		del_targets()
		count()
	elif  choice =="3":
		del_scan()
		count()
	elif  choice =="4":
		count()
	else:
		print "请重新运行并请输入1、2、3、4选择。"

#下图的注释信息是删除通知。。
"""
counter= 0
for website in all_info.get("notifications"):
	if (website["data"].get("address")== "www.ly.com"):
		counter = counter + 1
		url_del = "https://172.16.1.144t:3443/api/v1/scans/"+str(website["data"].get("scan_id"))
		print url_del#print url_del
		req_del = urllib2.Request(url_del,headers=send_headers2)
 #DELETE方法
	try:
		req_del.get_method = lambda:"DELETE"
		response1 = urllib2.urlopen(req_del)

	except:
		print "error"
		continue
		print counter
#print response1.read()
#for address in need_info["address"]:
#	if address:
#del_all()
"""
