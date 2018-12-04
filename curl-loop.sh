#!/bin/bash
#一个简单的自定义时间的循环任务，循环时间按秒计算
SLEEP_TIME=$1
HOST_NUMBER=$2
LOG_PATH=/var/log/curl-loop.log
while true
do
#循环内容，请自定义
date +"%y-%m-%d %H:%M:%S" >$LOG_PATH
curl -s "http://sdsdwesdfsdfsdfa.gstai.com/$HOST_NUMBER" >>$LOG_PATH
#以上为循环主体
sleep $SLEEP_TIME
done
