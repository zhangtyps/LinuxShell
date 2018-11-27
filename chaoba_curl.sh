#!/bin/bash
#check_path为对照文本，如果删减机器请修改文本内容
check_path=/home/zhangtianyu/chaoba.txt
#access_path为抓取文本的放置位置，此文本和上面txt_path做比对
access_path=/home/zhangtianyu/now-access.log
#for_path为存放检测结果的文本位置
for_path=/home/zhangtianyu/z.log

cat /opt/proxyall.log | awk '{print $7}' | sort |uniq -c |awk '{print $2}' |cut -f2 -d "/" &>$access_path
check_time=`date +%s`
for i in `cat $check_path`
do
#循环比对hostname是否存在
NUMRE=`grep $i $access_path`
#此if条件下的$i都为故障机器
	if [ -z $NUMRE ];then
	#写错误日志模块
	#判断错误日志里是否存在这个host
	is_broken=`grep $i $for_path`
		if [[ -z $is_broken ]];then
		#未找到该host，则记录错误host到日志中，同时记录时间
		echo "$check_time $i time:0" &>>$for_path
		else
		#找到该host，计算故障时间
		old_down_time=`grep $i $for_path | awk '{print$1}'`
		failure_duration=`expr $check_time - $old_down_time`
		#找到该机器这一行
		line_num=`grep -n $i z.log | cut -d: -f1`
		sed -i "$line_num s/time:.*/time:$failure_duration/" $for_path
		fi
	#此else条件下的$i均为正常的机器
	else
	#存在，则删除错误日志里该行
	sed -i -e "/$i/d" $for_path
	fi
done
#统计完毕，清空对应日志
#注意，如果需要频繁运行此脚本，请注释下面的清空语句
true >/opt/proxyall.log &>/dev/null

