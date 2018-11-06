#!/usr/bin/env python
#coding:utf8
#
import MySQLdb as mysql
import re
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText

def sendHtmlMail(mailcontent,myip):
    try:
        yestoday=(datetime.now()-timedelta(days=1)).strftime("%Y-%m-%d")
        sender = ''
        receiver = ['']
        subject = myip+' mysql operation report '+yestoday
        smtpserver = 'smtp.exmail.qq.com'
        username = 'wiki@you are  a son such of bitch''
        password = 'you are  a son such of bitch and the new password is 68656c6c6f20636f6d7075746572'
        msg = MIMEText(mailcontent,'html','utf-8')
        msg['Subject'] = subject
        msg['From'] = sender
        msg['To'] = ''
        smtp = smtplib.SMTP()
        smtp.connect(smtpserver)
        smtp.login(username, password)
        smtp.sendmail(sender, receiver, msg.as_string())
        smtp.quit()
    except Exception, e:
        print e,'send mail error'
if __name__=='__main__':
    result=None
    htmlfile='mysqlSlowMon.html'
    myiplist=['10.10.89.134','10.10.88.103','10.10.89.147','10.10.16.212']
    yestoday=(datetime.now()-timedelta(days=1)).strftime("%Y-%m-%d 00:00:00")
    today=datetime.now().strftime("%Y-%m-%d 00:00:00")
    for myip in myiplist:
        sql="select start_time,user_host,query_time,lock_time,rows_sent,sql_text from slow_log_dba where start_time >='%s' and start_time <='%s' order by query_time desc limit 500" % (yestoday,today)
#        sql="select start_time,user_host,query_time,lock_time,rows_sent,sql_text from slow_log_dba where start_time >='2017-06-27 00:00:00' and start_time <='2017-06-28 23:59:59' order by query_time desc  limit 5;"
        try:
            if myip == "10.10.89.134" or myip == "10.10.89.147":
                mysql_Port=3307 
            elif myip == "10.10.88.103" or myip == "10.10.16.212":
                mysql_Port=3306
            else:
		pass
            dbcon = mysql.connect(host=myip, user='operate', passwd='4w2w2operate2017', db='mysql', port=mysql_Port,charset='utf8')
            cur = dbcon.cursor()
            print "step 1,"+myip+','+datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            cur.execute(sql)
            result = cur.fetchall()
            cur.close()
            dbcon.close()
        except Exception, e:
            print e,'conn mysql error'
        print "step 2,"+myip+','+datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if result:
            headhtml='''<!DOCTYPE html><html class=" MacOS"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><style type="text/css">
         #customers {
            FONT-FAMILY: "Trebuchet MS", Arial, Helvetica, sans-serif; WIDTH: 100%; BORDER-COLLAPSE: collapse
        }
         #customers TD {
            BORDER-TOP: #98bf21 1px solid; BORDER-RIGHT: #98bf21 1px solid; BORDER-BOTTOM: #98bf21 1px solid; PADDING-BOTTOM: 2px; PADDING-TOP: 3px; PADDING-LEFT: 7px; BORDER-LEFT: #98bf21 1px solid; PADDING-RIGHT: 7px
        }
         #customers TH {
            BORDER-TOP: #98bf21 1px solid; BORDER-RIGHT: #98bf21 1px solid; BORDER-BOTTOM: #98bf21 1px solid; PADDING-BOTTOM: 2px; PADDING-TOP: 3px; PADDING-LEFT: 7px; BORDER-LEFT: #98bf21 1px solid; PADDING-RIGHT: 7px
        }
         #customers THEAD {
            FONT-SIZE: 1.0em; COLOR: #fff; PADDING-BOTTOM: 4px; TEXT-ALIGN: left; PADDING-TOP: 5px; BACKGROUND-COLOR: #a7c942
        }
         #customers TR.alt TD {
            COLOR: #000; BACKGROUND-COLOR: #eaf2d3
        }
        </style>
            </head><body>
            <table id="customers" align="center" style="width:90%;">
                        <thead><tr align="left">
                            <td>执行时间</td>
                            <td>用户</td>
                            <td>查询时长/s</td>
                            <td>加锁时长/s</td>
                            <td>发送行数目/line</td>
                            <td>执行sql</td>
                        </tr></thead><tbody>'''
            with open(htmlfile,'w') as htmlfileobj:
                htmlfileobj.write(headhtml)
                htmlfileobj.flush()
            for start_time,user_host,query_time,lock_time,rows_sent,sql_text in result:
                sql=re.compile(r'(\/\*(\s|.)*?\*\/)').sub("",sql_text)[0:150].replace(u"\x00",'').strip()
                if not sql or sql.strip()=='' or sql.strip()==' ':
                    continue
                with open(htmlfile,'a') as htmlfileobj:
                    tmpstring='<tr align="left"><td>'+str(start_time)+'</td><td>'+user_host+'</td><td>'+str(query_time)+'</td><td>'+str(lock_time)+'</td><td>'+str(rows_sent)+'</td><td>'+sql+'</td></tr>'
                    htmlfileobj.write(tmpstring)
            with open(htmlfile,'a') as htmlfileobj:
                tmpline='''</tbody></table></html>'''
                htmlfileobj.write(tmpline)
            with open(htmlfile,'r') as htmlfileobj:
                mailcontent=htmlfileobj.read()
            print "step 3,"+myip+','+datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            sendHtmlMail(mailcontent,myip)
        else:
            print 'sql result is None,exit ing'
        print "step 4,"+myip+','+datetime.now().strftime("%Y-%m-%d %H:%M:%S")
