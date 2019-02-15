#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#检测进程监听的状态，自动重启挂了的端口监听进程
#ver1.1 修正一些bug，优化了输出结果

#定义需要检查的进程
process[0]="nginx"
process[1]="php-fpm"
process[2]="zabbix_agentd"

function get_time() {
    echo `date +'%Y-%m-%d %H:%M:%S'`
}

function check_process() {
    num=`netstat -ntpl | grep $1 | wc -l`
    if [ $num -ge 1 ];then
        echo "$1 is running..."
    else
        service $1 restart &>/dev/null
        if [ $? -eq 0 ];then
            echo "$1 has been restarted successfully!"
        else
            echo "$1 restart failed!"
        fi
    fi
}

#main
i=0
get_time
while [ $i -lt ${#process[@]} ]
do
    check_process ${process[i]}
    let i++
done