#!/bin/bash
#访问我的GitHub获取最新的代码：https://github.com/zhangtyps
#从各个代理机取日志
#version 1.0

#取脚本最外层绝对路径
SCRIPT_PATH=`pwd`

#需要取日志的机器，分开取不同密码的机器
host_path_cb=$SCRIPT_PATH/host/host-cb.txt
host_path_yg=$SCRIPT_PATH/host/host-yg.txt
host_path_bs=$SCRIPT_PATH/host/host-bs.txt
#用户名及密码
user_cb=root
passwd_cb='root'
user_yg=root
passwd_yg='root'
user_bs=root
passwd_bs='root'
#本地保存的路径
download_path=$SCRIPT_PATH/log/
#远程目标文件的路径
destination_path=/mnt/count.log
#fuck_log的输出结果
output=$SCRIPT_PATH/output.log

#脚本运行日志
log_path_success=$SCRIPT_PATH/temp/sshpass_success.log
log_path_fail=$SCRIPT_PATH/temp/sshpass_fail.log
log_path_fail_temp=$SCRIPT_PATH/temp/sshpass_temp.log

# #失败重新运行
# if [[ $1 -eq 1 ]];then
# cat $log_path_fail | awk '{print$1}' >$log_path_fail_temp
# host_list=$log_path_fail_temp
# if [[ -z `cat $host_list` ]];then
# echo "失败日志为空，程序退出"
# exit 0
# fi
# fi

#清空日志
true >$log_path_success
true >$log_path_fail

function get_log() {
    #预定为4个参数，平台-主机名-用户名-密码
    platform=$1
    host_list=$2
    username=$3
    passwd=$4
    while read line
    do
    {
        ip=${line%:*}
        port=${line#*:}
        #分发文件
        sshpass -p $passwd scp -o StrictHostKeyChecking=no -P $port $username@$ip:$destination_path $download_path/$platform/$ip:$port.log
        if [ $? -eq 0 ];then
        echo "$ip:$port 下载成功" | tee -a $log_path_success
        #let success_host++
        else
        echo "$ip:$port 失败" | tee -a $log_path_fail
        #let fail_host++
        fi } &
    done < $host_list
    wait
}


# #任务结束控制台输出
# success_host=$(wc -l $log_path_success | awk '{print$1}')
# fail_host=$(wc -l $log_path_fail | awk '{print$1}')
# cat <<EOF
# ——————————————————
# —————分发任务已结束——————
# 成功:	$success_host 台
# 失败：	$fail_host 台
# ——————————————————
# ——————————————————
# EOF
# if [ $fail_host -gt 0 ];then
# cat <<EOF
# 分发失败主机日志：$log_path_fail
# 控制台输入“$0 1”进行失败重传
# EOF
# fi

function fuck_log() {
    host_path=$1
    while read line
    do
        sum_requests=`cat $(find $download_path -name ${line}*) | grep -E '请求量' | grep -Eo '[0-9]+'`
        sum_success=`cat $(find $download_path -name ${line}*) | grep -E '成功率' | grep -Eo '[0-9]+|[0-9]+\.[0-9]+'`
        echo "$line $sum_requests $sum_success" >>$output
    done <$host_path
}


#清空上一次的记录
rm -rf $download_path/cb/*
rm -rf $download_path/bs/*
rm -rf $download_path/yg/*
#调用方法下载日志
get_log cb $host_path_cb ${user_cb} ${passwd_cb}
get_log yg $host_path_yg ${user_yg} ${passwd_yg}
get_log bs $host_path_bs ${user_bs} ${passwd_bs}
#清空输出文件
:>$output
#处理所有日志并输出
fuck_log $host_path_yg
fuck_log $host_path_cb
fuck_log $host_path_bs