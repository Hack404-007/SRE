#!/usr/bin/env python
# -*- coding:utf8 -*-
try: 
    import httplib
except ImportError:
    import http.client as httplib
import sys,datetime
import urllib
#import urllib.request
#import urllib.error
#import urllib.parse
#from urllib import parse 
import urllib2
import time
import json
import base64
import hmac,ssl
import uuid
from hashlib import sha1
# 解决 访问ssl网站证书的问题
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context

import json
import argparse
import os
import sys
reload(sys)
sys.setdefaultencoding( "utf-8" )
#sys.setdefaultencoding( "gbk" )


#expired_threshold = 10 


class aliyunclient:
    def __init__(self):
        self.access_id = 'mfzsrhcqdxiaCYjV'
        self.access_secret ='JznqaztzWKoQnpBc3ZlC6cIcqyIsvs'
        #监控获取ECS URL
        self.url = 'https://ecs.aliyuncs.com'
    # #签名
    def sign(self,accessKeySecret, parameters):
        sortedParameters = sorted(parameters.items(), key=lambda parameters: parameters[0])
        canonicalizedQueryString = ''
        for (k,v) in sortedParameters:
            canonicalizedQueryString += '&' + self.percent_encode(k) + '=' + self.percent_encode(v)
        stringToSign = 'GET&%2F&' + self.percent_encode(canonicalizedQueryString[1:])  # 使用get请求方法
        bs = accessKeySecret +'&'
        #bs = bytes(bs,encoding='utf8')
        bs = bytes(bs)
        #stringToSign = bytes(stringToSign,encoding='utf8')
        stringToSign = bytes(stringToSign)
        h = hmac.new(bs, stringToSign, sha1)
        # 进行编码
        signature = base64.b64encode(h.digest()).strip()
        return signature
    def percent_encode(self,encodeStr):
        encodeStr = str(encodeStr)
        #res = urllib.request.quote(encodeStr)
        res = urllib2.quote(encodeStr)
        res = res.replace('+', '%20')
        res = res.replace('*', '%2A')
        res = res.replace('%7E', '~')
        return res
    # 构建除共公参数外的所有URL
    def make_url(self,params):
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        parameters = {
            'Format' : 'JSON',
            'Version' : '2014-05-26',
            'AccessKeyId' : self.access_id,
            'SignatureVersion' : '1.0',
            'SignatureMethod' : 'HMAC-SHA1',
            'SignatureNonce' : str(uuid.uuid1()),
            'Timestamp' : timestamp,
        }
        for key in params.keys():
            parameters[key] = params[key]
        signature = self.sign(self.access_secret,parameters)
        parameters['Signature'] = signature
        #url = self.url + "/?" + urllib.parse.urlencode(parameters)
        url = self.url + "/?" + urllib.urlencode(parameters)
        return url
    def do_action(self,params):
        url = self.make_url(params)
        request = urllib2.Request(url)
        try:
            conn = urllib2.urlopen(request)
            response = conn.read()
        except urllib2.HTTPError as e:
            print(e.read().strip())
            raise SystemExit(e)
        try:
            res = json.loads(response)
        except ValueError as e:
            raise SystemExit(e)
        return res
# 继承原始类
#class client(RegionId,InstanceIds):
class client(aliyunclient):
    def __init__(self,RegionId,InstanceIds):
        aliyunclient.__init__(self)
        self.InstanceIds = InstanceIds
        # ECS 区域
#        self.RegionId = "cn-shanghai"
        self.RegionId = RegionId 

    # 时间UTC转换
    def timestrip(self):
        UTCC = datetime.datetime.utcnow()
        utcbefore5 = UTCC - datetime.timedelta(minutes =5)
        Endtime = datetime.datetime.strftime(UTCC, "%Y-%m-%dT%H:%M:%SZ")
        StartTime = datetime.datetime.strftime(utcbefore5, "%Y-%m-%dT%H:%M:%SZ")
        return (StartTime,Endtime)
    def DescribeInstanceMonitorData(self):
        '''
        构造实例监控序列函数
        '''
        self.tt = self.timestrip()
        action_dict ={"StartTime":self.tt[0],"Endtime":self.tt[1],"Action":"DescribeInstanceMonitorData","RegionId":self.RegionId,"InstanceId":self.InstanceId}
        return action_dict
    def DescribeInstances(self):
        '''
        构建实例配置查询函数
        '''
        action_dict = {"PageSize":100,"Action":"DescribeInstances","RegionId":self.RegionId,"InstanceIds":self.InstanceIds}
        return action_dict
    def alis_main(self):
        res2 = self.do_action(self.DescribeInstances())
        return  res2

def DescribeInstanceStatus(RegionId):
    '''
    构建实例配置查询函数
    '''
    action_dict = {"Action":"DescribeInstanceStatus","RegionId":RegionId,"PageSize":50}
    return action_dict


#if __name__ == "__main__":
def make_host_data():
    # 传实例ID 列表进去
    #aliyun = aliyunclient()
    # 检查的区域
    #RegionId = "cn-beijing"
    RegionId_list = {"cn-shenzhen":"华南1","cn-beijing":"华北2","cn-hangzhou":"华东1","cn-shanghai":"华东2"}

    host_list = []
    for RegionId, RegionName in RegionId_list.items():
        #获取区域RegionId
        aliyun = aliyunclient()
        DescribeInstanceStatus_param = DescribeInstanceStatus(RegionId)
        res = aliyun.do_action(DescribeInstanceStatus_param)
        putdata =  dict(res)
        id_data =  putdata['InstanceStatuses']['InstanceStatus']
        instanceId_list = []
        #构造RegionId 队列
        for id_single in id_data:
            instanceId_list.append(str(id_single['InstanceId']))
        #获取当前区域各esc服务器信息
        clt= client(RegionId,instanceId_list)
        res = clt.alis_main()
        for singe_ms in  res['Instances']['Instance']:
            host_list.extend(singe_ms['PublicIpAddress']['IpAddress'])

    host_inventory = {}
    host_inventory['aly_all'] = {}
    host_inventory['aly_all']['hosts'] = []
    hosts_key = {}
    hosts_key['ansible_port'] = '60086'
#    host_inventory['aly_all']['vars']= hosts_key 

    for host in host_list:
        host_key = {}
        hostname = 'aly_' + host.replace('.','_')
        host_inventory[hostname] = {}
        host_inventory[hostname]['hosts'] = []
        host_inventory[hostname]['hosts'].append(hostname) 
        host_inventory['aly_all']['hosts'].append(host)
        host_key['ansible_host'] = host
        host_key['ansible_port'] = '60086'
        host_inventory[hostname]['vars']= host_key
        #host_inventory[hostname]['ansible_user'] = 'root'
        
    #return json.dumps(host_inventory,indent=2)
    return host_inventory

def getList():
    data = make_host_data()
    print json.dumps(data,indent=2)
    
    
def getVars(host):
    data = make_host_data()
    print json.dumps(data[host]["vars"],indent=2)
    
    
if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--list',action='store_true',dest='list',help='get all hosts')
    parser.add_argument('--host',action='store',dest='host',help='get all hosts')
    args = parser.parse_args()

    if args.list:
        getList()

    if args.host:
        getVars(args.host)
