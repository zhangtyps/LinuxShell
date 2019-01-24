#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#check_path为对照文本，如果删减机器请修改文本内容
check_path=/home/zhangtianyu/curl_Alarm/shell_temp/chaoba.txt
#access_path为超巴抓取文本的放置位置，此文本和上面txt_path做比对
access_path=/home/zhangtianyu/curl_Alarm/shell_temp/access_cb.log
#for_path为存放检测结果的文本位置
for_path=/home/zhangtianyu/curl_Alarm/shell_temp/output_cb.log
#邮件相关参数
FILE_DEMO=/home/zhangtianyu/curl_Alarm/shell_temp/cb_mail.log
MAIL_PATH=/home/zhangtianyu/curl_Alarm/mail.sh
FILE=/var/log/cb_checkhost_sendmail.txt
SUBJECT="超巴host代理检测告警"

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
	line_num=`grep -n $i $for_path | cut -d: -f1`
	sed -i "$line_num s/time:.*/time:$failure_duration/" $for_path
	fi
#此else条件下的$i均为正常的机器
else
#存在，则删除错误日志里该行
sed -i -e "/$i/d" $for_path
fi
done


#格式化文本模块
echo -e "主机名|累计故障(小时)|上一次故障" >$FILE_DEMO
line_num=`wc -l $for_path | awk '{print $1}'`
cat $for_path | while read line
do
downtime=`echo "${line}" | awk '{print$1}'`
err_host=`echo "${line}" | awk '{print$2}'`
lastlong=`echo "${line}" | awk '{print$3}'`
#修改故障时间的格式
newtime=`echo $lastlong | cut -b 6-`
lastlong=`echo "scale=2; $newtime / 3600" | bc`
if [[ `echo $lastlong | cut -b 1` = "." ]];then
lastlong="0$lastlong"
fi
#修改首次故障时间
downtime_date=`date -d @$downtime +"%y-%m-%d %H:%M:%S"`
echo "$err_host|   $lastlong|$downtime_date" >>$FILE_DEMO
done
#自动排版
column -t -s '|' $FILE_DEMO >$FILE


#发送邮件模块
if [ `cat $for_path | wc -l` -eq 0 ];then
exit 0
fi
$MAIL_PATH zhangtianyu@yuqing.gsdata.cn $SUBJECT $FILE
$MAIL_PATH wangyang@yuqing.gsdata.cn $SUBJECT $FILE
$MAIL_PATH helesong@yuqing.gsdata.cn $SUBJECT $FILE

