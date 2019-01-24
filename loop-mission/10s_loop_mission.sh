#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#简单的循环执行命令，此为10秒执行一次，在定时任务里1分钟启动一次
COUNT=0
while true
do
let COUNT++
echo "循环 $COUNT"
svn up /data1/www/changan_dev/
if [ $COUNT -eq 6 ];then
echo "程序退出"
exit 0
fi
sleep 10
done
