#-------------------------------------------------------------------------------
# Name:        Alarm Email
# Purpose:
#
# Author:      AlexChen
#
# Created:     20/05/2016
# Copyright:   (c) AlexChen 2016
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import signal
import logging
import MySQLdb
import smtplib
import time
from email.mime.text import MIMEText
from email.header import Header
from email.mime.multipart import MIMEMultipart


flag = True
def ExitHandle(s,e):
    flag = False
    raise SystemExit('\r\nEXIT!!!')

config_dict = {
                'Log':{     'level':'debug',
                            'console':True,
                            'file':'AlarmEmail'
                        },
                'Sys':{     'db_host':'172.16.5.34',
                            'db_user':'root',
                            'db_pwd':'123456',
                            'db_table':'ucpaas_smsp',
                            'sender':'alarm@ucpaas.com',
                            'password':'ucpaas.com',
                            'subject':'Channel alarm mail!'
                        }
            }

### LogPy:Log modle

class LogPy():
    def __init__(self, log_level = 'debug', module_name = 'test', file_name = 'test', console_log = False):
        self.log_level = log_level
        self.module_name = module_name
        self.file_name = file_name
        self.console_log = console_log
        self.logger = logging.getLogger(self.module_name)
        self.logger.setLevel(logging.DEBUG)

    def SetLogLevel(self, logger):
        log_level = self.log_level
        if log_level == '':
            logger.setLevel(logging.DEBUG)
            return logger

        if cmp(log_level.lower(), 'debug') == 0:
            logger.setLevel(logging.DEBUG)
        elif cmp(log_level.lower(), 'info') == 0:
            logger.setLevel(logging.INFO)
        elif cmp(log_level.lower(), 'warning') == 0:
            logger.setLevel(logging.WARNING)
        elif cmp(log_level.lower(), 'fatal') == 0:
            logger.setLevel(logging.FATAL)
        elif cmp(log_level.lower(), 'error') == 0:
            logger.setLevel(logging.ERROR)
        elif cmp(log_level.lower(), 'critical') == 0:
            logger.setLevel(logging.CRITICAL)
        else:
            logger.setLevel(logging.DEBUG)

        return logger

    def GetLogFormatter(self):
        formatter = logging.Formatter('[%(process)d][%(asctime)s][%(levelname)s][%(module)s::%(funcName)s:%(lineno)d] %(message)s')
        return formatter

    def GetFileLog(self):
        file_name = self.file_name + '.log'
        if file_name == '':
            file_name = 'default_f.log'

        filename = './' + file_name

        fh = logging.FileHandler(filename)
        file_log = self.SetLogLevel(fh)
        formatter = self.GetLogFormatter()
        file_log.setFormatter(formatter)
        self.logger.addHandler(file_log)

    def GetConsoleLog(self):
        ch = logging.StreamHandler()
        console_log = self.SetLogLevel(ch)
        formatter = self.GetLogFormatter()
        console_log.setFormatter(formatter)
        self.logger.addHandler(console_log)

    def PrintLog(self):
        if self.console_log == True:
            self.GetConsoleLog()
        self.GetFileLog()

        return self.logger

################################################################################
def LogCS(module_name):
    log_dict = config_dict['Log']
    return LogPy(log_dict['level'], module_name, log_dict['file'], log_dict['console']).PrintLog()

LOG = LogCS('AlarmEmail')

################################################################################


class MySQL:
    def __init__(self, host, user, pwd, db):
        self.host = host
        self.user = user
        self.pwd = pwd
        self.db = db

    def GetConnect(self):
        if not self.db:
            raise(NameError,"No imformation about DB!")
            LOG.warning("No imformation about DB!")

        self.conn = MySQLdb.connect(host=self.host, user=self.user, passwd=self.pwd, db=self.db, port=3306)
        cur = self.conn.cursor()
        if not cur:
            raise(NameError,"Connect DB is failed!")
            LOG.warning("Connect DB is failed!")
        else:
            return cur

    def ExecQuery(self, sql):
        cur = self.GetConnect()
        cur.execute(sql)
        relust_list = cur.fetchall()
        cur.close()
        self.conn.close()
        return relust_list

    def ExecNonQuery(self, sql):
        cur = self.GetConnect()
        result = cur.execute(sql)
        self.conn.commit()
        cur.close()
        self.conn.close()
        return result

class AlarmEmail():
    def __init__(self, sender, password):
        self.sender = sender
        self.password = password

    def CreateMail(self, header, body, attachment):
        mail = MIMEMultipart()
        for k in header:
            if k == 'subject':
                mail[k] = Header(header[k], 'utf-8')
            elif k == 'to' and isinstance(header[k], list):
                mail[k] = ','.join(header[k])
            else:
                mail[k] = header[k]
        for k in body:
            if k == 'text':
                body_plain = MIMEText(body['text'], 'plain', 'utf-8')
                mail.attach(body_plain)
            elif k == 'html':
                body_html = MIMEText(body['html'], 'html', 'utf-8')
                mail.attach(body_html)
        if attachment:
            for x in range(len(attachment)):
                try:
                    print str(x) + "    " + str(attachment[x]['path'])
                    atta_file = open(attachment[x]['path'], 'rb')
                except Exception, e:
                    print "Exception1   " + str(e)
                    continue
                try:
                    atta_file_content = atta_file.read()
                except Exception, e:
                    print "Exception2   " + str(e)
                    continue
                atta = MIMEText(atta_file_content, 'base64', 'utf-8')
                atta['Content-Type'] = 'application/octet-stream'
                atta['Content-Disposition'] = 'attachment; filename=' + attachment[x]['name']
                mail.attach(atta)
        mail = mail.as_string()
        return mail

    def SendMail(self, receiver, subject, text='', html='', attachment='', sender=''):
        if not text and not html and not attachment:
            return
        if not sender:
            sender = self.sender
        header = {
            'from' : sender,
            'to' : receiver,
            'subject' : subject
        }
        body = {}
        if text:
            body['text'] = text
        if html:
            body['html'] = html
        mail = self.CreateMail(header, body, attachment)
        try:
            smtp = smtplib.SMTP()
            smtp.connect('mail.ucpaas.com')
            smtp.login(self.sender, self.password)
            smtp.sendmail(self.sender, receiver, mail)

            smtp.quit()
            return True
        except Exception, e:
            return False,e



def Process():
    global flag
    result_list = []
    sys_dict = config_dict['Sys']

    while(flag):
        result_list = ()
        time.sleep(10)
        try:
            ms = MySQL(sys_dict['db_host'], sys_dict['db_user'], sys_dict['db_pwd'], sys_dict['db_table'])
            result_list = ms.ExecQuery("select id,mail_address,mail_content from t_sms_send_warn where status=2")
            if 0 != len(result_list):
                LOG.debug("%s",str(result_list))
                for result in result_list:
                    receiver = []
                    text = ''
                    receiver = result[1].split(',')
                    text = result[2]
                    ae = AlarmEmail(sys_dict['sender'], sys_dict['password'])
                    a = ae.SendMail(receiver, sys_dict['subject'], text, '', '', sys_dict['sender'])
                    if True == a:
                        ms.ExecNonQuery("delete from t_sms_send_warn")
                        LOG.debug("Send alarm is successful!")
                    else:
                        LOG.debug("Send alarm is failed!")
        except Exception, e:
            LOG.warning("e:%s", str(e))
			
def Process1():
    global flag
    result_list = []
    sys_dict = config_dict['Sys']

  
	result_list = ()
	
	try:
		ms = MySQL(sys_dict['db_host'], sys_dict['db_user'], sys_dict['db_pwd'], sys_dict['db_table'])
		result_list = ms.ExecQuery("select id,mail_address,mail_content from t_sms_send_warn where status=2")
		if 0 != len(result_list):
			LOG.debug("%s",str(result_list))
			for result in result_list:
				receiver = []
				text = ''
				receiver = result[1].split(',')
				text = result[2]
				ae = AlarmEmail(sys_dict['sender'], sys_dict['password'])
				a = ae.SendMail(receiver, sys_dict['subject'], text, '', '', sys_dict['sender'])
				if True == a:
					ms.ExecNonQuery("delete from t_sms_send_warn")
					LOG.debug("Send alarm is successful!")
				else:
					LOG.debug("Send alarm is failed!")
	except Exception, e:
		LOG.warning("e:%s", str(e))

def main():
    signal.signal(signal.SIGINT, ExitHandle)
    try:
        Process1()
        sys.exit()
    except Exception, e:
        LOG.warning("e:%s", str(e))

if __name__ == '__main__':
    main()
