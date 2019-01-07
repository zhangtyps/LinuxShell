#!/bin/bash
SCRIPT_NAME=curl.sh
SCRIPT_LOG=/var/log/curl.log
LOOPTIME=$1
HOSTNUM=$2

date +"%y-%m-%d %H:%M:%S"
ps aux | grep $SCRIPT_NAME | grep -v grep &>/dev/null
if [ $? -ne 0 ];then
    echo "未查找到进程，正在启动脚本"
    SCRIPT_PATH=$(find /home -name "$SCRIPT_NAME")
    $SCRIPT_PATH $LOOPTIME $HOSTNUM &>/dev/null &
    echo "脚本已重启"
else
    echo "脚本进程似乎是正常，正在检测脚本是否在偷懒"
    LOGTEXT1=$(sed -n 1p $SCRIPT_LOG)
    LOGTEXT2=$(sed -n 2p $SCRIPT_LOG)
    if [[ -z $LOGTEXT2 ]];then
        echo "日志第二行为空，极有可能是curl命令卡住了，正在判断日志时间"
        UNIXTIME=$(date -d "$LOGTEXT1" +%s)
        NOWTIME=`date +%s`
        LAZYTIME=`expr $NOWTIME - $UNIXTIME`
        echo "当前脚本偷懒了 $LAZYTIME 秒"
        if [ $LAZYTIME -gt $[ $LOOPTIME * 2 + 10 ] ];then
            echo "偷懒时间过长，正在重启脚本"
            ps aux | grep curl.sh | grep -v grep | awk '{print $2}' | xargs kill -9
            SCRIPT_PATH=$(find /home -name "$SCRIPT_NAME")
            $SCRIPT_PATH $LOOPTIME $HOSTNUM &>/dev/null &
            echo "脚本已重启"
        else
            echo "偷懒时间未达到设定值，等待下一轮检测"
        fi
    else
        echo "检测到内容日志正常，脚本不在偷懒，检测程序退出"
    fi
fi
