#!/bin/bash
#服务器远程分发文件脚本，适用于给大量账户密码相同的客户机快速分发文件（多线程分发）
#需要安装sshpass以实现此脚本核心功能，yum install sshpass
#运行脚本时带入参数1则根据失败日志进行重发

#需要自行改动的参数
#本地服务器提供文件的地址
download_path=/home/wangyang/download/*
#客户机接收文件的地址
destination_path=/home/chaobaproxy/
#客户机列表文件的地址，通过循环遍历此文件确定分发的客户机IP和端口
#文件内容格式请样式填写，如 192.168.12.1:22
host_list=/home/wangyang/scp_ssh/chaoba.txt
#客户机账号
username=root
#客户机密码
passwd='root'


#脚本运行产生日志
log_path_success=/var/log/sshpass_success.log
log_path_fail=/var/log/sshpass_fail.log
log_path_fail_temp=/var/log/sshpass_temp.log

#失败重新运行模块
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
else
echo "$ip:$port 失败" | tee -a $log_path_fail
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
