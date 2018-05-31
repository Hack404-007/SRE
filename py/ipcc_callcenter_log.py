#!/usr/bin/env pyhton
#coding:utf8
#author: by Gandolf.Tommy
#time: 2017-06-06

import os
import time
import datetime

TTS_PATH='/opt/ipcc/tts/'
RECORD_PATH='/tmp/recordUpload/'
SWITCH_PATH='/opt/ipcc/freeswitch-1.4.20-2.1.10.3/log/'


def delete_log(file_path,expire_days):
	f = list(os.listdir(file_path))
	for i in range(len(f)):
		filedate = os.path.getmtime(file_path + f[i])
		time1 = datetime.datetime.fromtimestamp(filedate).strftime('%Y-%m-%d')
		date1 = time.time()
		num1 = (date1 - filedate)/60/60/24
		if num1 >= expire_days:
			os.remove(file_path + f[i])
			print "[+] 已删除文件: %s : %s" % (time1, f[i])
	else:
		print "[!] There are no file more than %d days" % (expire_days)

if __name__ == "__main__":
	delete_log(TTS_PATH,1)
	delete_log(RECORD_PATH,15)
	delete_log(SWITCH_PATH,30)	
