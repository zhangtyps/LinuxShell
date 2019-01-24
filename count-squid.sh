#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#根据squid请求日志计算代理请求成功率
Filename=`find / -name access.log`
echo "------------------------------------------------------------------------------------------"
Num=`cat $Filename |wc -l`
echo "代理请求总量：" $Num

Num200=`cat $Filename | grep "/200" | wc -l`
Num301=`cat $Filename | grep "/301" | wc -l`
Num302=`cat $Filename | grep "/302" | wc -l`
Num304=`cat $Filename | grep "/304" | wc -l`
Numsuccess=$[$Num304+$Num302+$Num301+$Num200]
Successpre=`awk 'BEGIN{printf "%.1f%%\n",('$Numsuccess'/'$Num')*100}'`
echo "代理请求成功率：" $Successpre

echo "代理请求url排名前10统计："
cat  $Filename |awk '{print  $7}' |sort -n |uniq -c | sort -n | tail -10 | awk '{print $1,$2}' |sort -hr

:<<!
echo "请求方式总量："
cat $Filename |awk '{print  $6}' |sort -r |uniq -c |sort -n |awk '{print $1,$2}' |sort -hr

echo "请求状态码结果："
cat $Filename  |awk '{print $4}' |sort -n |uniq -c | awk '{print $1,$2}' |sort -hr
!
echo "------------------------------------------------------------------------------------------"
