#!/bin/bash
#日志抓取分类模块，统一抓取并清空，以供后面脚本使用
#检测脚本
cb_check=/home/zhangtianyu/curl_Alarm/cb_checkhost.sh
yg_check=/home/zhangtianyu/curl_Alarm/yg_checkhost.sh
bs_check=/home/zhangtianyu/curl_Alarm/bs_checkhost.sh

#各个抓取文本的位置
access_path_cb=/home/zhangtianyu/curl_Alarm/shell_temp/access_cb.log
access_path_yg=/home/zhangtianyu/curl_Alarm/shell_temp/access_yg.log
access_path_bs=/home/zhangtianyu/curl_Alarm/shell_temp/access_bs.log

cat /opt/proxyall.log | awk '{print $7}' | sort |uniq -c |awk '{print $2}' |cut -f2 -d "/" | grep "^cb" &>$access_path_cb
cat /opt/proxyall.log | awk '{print $7}' | sort |uniq -c |awk '{print $2}' |cut -f2 -d "/" | grep "^yg" &>$access_path_yg
#cat /opt/proxyall.log | awk '{print $7}' | sort |uniq -c |awk '{print $2}' |cut -f2 -d "/" | grep "^bs" &>$access_path_bs

#调用检测脚本
$cb_check &
$yg_check &
#$bs_check &

#统计完毕，清空对应日志
#注意，如果需要频繁运行此脚本，请注释下面的清空语句
true >/opt/proxyall.log &>/dev/null
