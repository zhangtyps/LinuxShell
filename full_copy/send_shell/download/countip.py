#!/usr/bin/python
#coding:utf-8
# 统计ip重复率
import commands
def Countall(slog,dlog):
  cmd1='''cat %s | awk {'print $3'} >%s'''%(slog,dlog)
  result=commands.getoutput(cmd1)
  cmd2='cat %s | wc  -l'%dlog
  dail_Count=int(commands.getoutput(cmd2))
  cmd3='cat %s | sort -n | uniq -c |wc -l'%dlog
  repeatdail_Count=int(commands.getoutput(cmd3))
  repeatip_Count=(dail_Count-repeatdail_Count)
  present_Repeatip=repeatip_Count/float(dail_Count)*100
  return '重复次数/拨号次数 %d/%d IP重复率%.2f%%' %(repeatip_Count,dail_Count,present_Repeatip);
if __name__ == '__main__':
 count_Info=Countall('/mnt/pppoe.log','/mnt/b.log')
 print (count_Info);
else:
 pass
