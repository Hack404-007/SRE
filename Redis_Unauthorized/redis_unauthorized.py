#coding:utf-8
#powered by Aedoo

import redis
import threading
import Queue
import time
import sys

class Redis_Unauthorized(threading.Thread):

    def __init__(self,queue):
        threading.Thread.__init__(self)
        self.__queue = queue

    def run(self):
        while not self.__queue.empty():
            ip = self.__queue.get()
            poc(ip)


def poc(ip):

    try:
        redis_connect = redis.Redis(host=ip,port=6379,socket_connect_timeout=0.5)
        redis_connect.set('redis','redis')
        redis_connect.expire('redis',1)
        sys.stdout.write('%s:6379 is UnAuthorized!!!\n' % (ip))
        # print '%s:6379 is UnAuthorized!!!' % (ip)

    except Exception,e:
        sys.stdout.write('Sorry!\n')
        # print 'Sorry!'
        pass

def main():
    threads = []
    thread_count = 2       #此处调整线程数,初始为2,线程数不要大于IP数量
    queue = Queue.Queue()

    redis_file = open('target.txt','r')
    lines = redis_file.readlines()
    for line in lines:
        line = line[:-1]
        queue.put(line)
    redis_file.close()

    for i in range(thread_count):
        threads.append(Redis_Unauthorized(queue))

    for i in threads:
        i.start()
    for i in threads:
        i.join()

if __name__ == '__main__':
    print '''
  ------------------------------------------------------
  |       ____          _ _     _   _                  |
  |      |  _ \ ___  __| (_)___| | | |_ __             |
  |      | |_) / _ \/ _` | / __| | | | '_ \            |
  |      |  _ <  __/ (_| | \__ \ |_| | | | |           |
  |      |_| \_\___|\__,_|_|___/\___/|_| |_|           |
  |                                                    |
  |  Powered by Aedoo , My HomePage:www.imsunshine.cn  |
  ------------------------------------------------------  
  '''
    time_start = time.time()
    main()
    print time.time()-time_start