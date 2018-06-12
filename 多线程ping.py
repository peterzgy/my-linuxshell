#!/usr/lib/python2.7
#coding=utf-8
txt_path = r'/home/super-zou/Desktop/读取IP后测试端口'
with open(txt_path + '/ip文件') as f:
    lines = f.readlines()#读取全部内容
host_list = [] #将IP写在数组中
for line in lines:
    host_list.append(line.rstrip())
#print(host_list)
#print(len(host_list))


import threading,subprocess
from time import ctime,sleep,time
import Queue

queue = Queue.Queue()

class ThreadUrl(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue
    def run(self):
        while True:
            host = self.queue.get()
            #ret=subprocess.call('ping -c 1 '+host,shell=True,stdout=open('C:\Users\Super\Desktop\ping的结果.txt','w'))
            ret = subprocess.call('ping -c 1 -w 1 ' + host, shell=True)
            if ret:
                print(" %s is down\n" % host)
            else:
                print(' %s is up\n' % host)
            self.queue.task_done()


def main():
    for i in range(100):
        t=ThreadUrl(queue)  #调用多线程类
        #join：如在一个线程B中调用threada.join()，则threada结束后，线程B才会接着threada.join()
        #往后运行。
        #setDaemon：主线程A启动了子线程B，调用b.setDaemaon(True)，则主线程结束时，会把子线程B也杀死，与C / C + +中得默认效果是一样的。
        t.setDaemon(True)
        t.start()
    for host in host_list:
        queue.put(host)
    queue.join()

start = time()
main()
print("Elasped Time:%s" % (time()-start))
