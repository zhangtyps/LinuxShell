#!/bin/bash
:<<INFO
@File : process_check.sh
@Time : 2019/02/19 11:49:39
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.2 优化了脚本结构
@Desc : 检测进程监听的状态，自动重启挂了的端口监听进程
INFO

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

function main() {
    i=0
    get_time
    while [ $i -lt ${#process[@]} ]
    do
        check_process ${process[i]}
        let i++
    done
}

main