#!/bin/bash
#需要自行改动的参数
download_path=/home/zhangtianyu/send_shell/download/*
destination_path=/home/helesong/
host_list=/home/zhangtianyu/send_shell/host/yangguang.txt
username=helesong
passwd='i@67P#IcZ#&A35ed'

#脚本运行日志
log_path_success=/var/log/sshpass_success.log
log_path_fail=/var/log/sshpass_fail.log
log_path_fail_temp=/var/log/sshpass_temp.log

#失败重新运行
if [[ $1 -eq 1 ]];then
cat $log_path_fail | awk '{print$1}' >$log_path_fail_temp
host_list=$log_path_fail_temp
if [[ -z `cat $host_list` ]];then
echo "失败日志为空，程序退出"
exit 0
fi
fi

#清空日志
true >$log_path_success
true >$log_path_fail

#程序主体
while read line
do
{
ip=${line%:*}
port=${line#*:}
#分发文件
sshpass -p $passwd scp -o StrictHostKeyChecking=no -P $port $download_path $username@$ip:$destination_path
if [ $? -eq 0 ];then
echo "$ip:$port 分发成功" | tee -a $log_path_success
#let success_host++
else
echo "$ip:$port 失败" | tee -a $log_path_fail
#let fail_host++
fi } &
done < $host_list
wait

#任务结束控制台输出
success_host=$(wc -l $log_path_success | awk '{print$1}')
fail_host=$(wc -l $log_path_fail | awk '{print$1}')
cat <<EOF
——————————————————
—————分发任务已结束——————
成功:	$success_host 台
失败：	$fail_host 台
——————————————————
——————————————————
EOF
if [ $fail_host -gt 0 ];then
cat <<EOF
分发失败主机日志：$log_path_fail
控制台输入“$0 1”进行失败重传
EOF
fi
