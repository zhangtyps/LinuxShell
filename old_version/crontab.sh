#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
true >/var/spool/cron/root
if [ -z $1 ];then
echo "未输入参数，0=公共，1=正文"
exit 0
fi
if [ $1 -eq 1 ];then
    if [ -z $2 ]||[ -z $3 ]||[ $2 -lt 0 ]||[ $3 -lt 0 ];then
    echo "未输入正文拨号时间或输入错误的数值，请重新输入"
    echo "参考格式：30分钟拨号则输入./crontab 1 30 0"
    echo "参考格式：2小时拨号则输入./crontab 1 0 2"
    exit 0
    fi
fi
#获取用户家目录路径
PATH_HOME=`cat /etc/passwd | grep -v "/sbin/nologin" | grep "/home/" | cut -d: -f6`
read -p "获取到用户家目录为$PATH_HOME，请查看是否正确(y/n，默认确定)?"
if [[ $REPLY = "n" ]];then
    echo "用户退出！"
    exit 0
fi
#查找对应文件是否存在
FIND1=`ls $PATH_HOME/pppoe.sh` &>/dev/null
FIND2=`ls $PATH_HOME/checkproxy.sh` &>/dev/null
FIND3=`ls $PATH_HOME/checkweibo.sh` &>/dev/null
FIND4=`ls $PATH_HOME/checkwx.sh` &>/dev/null

if [ -z $FIND1 ] && [ -z $FIND2 ] && [ -z $FIND3 ] && [ -z $FIND4 ];then          
    echo "【未找到部分脚本，程序退出】"
else
    echo "~~脚本全部找到，正在根据参数进行设置，当前参数为: $1"
RNUM=`shuf -i 15-30 -n 1`
        if [ $1 -eq 0 ];then
                    echo "#pppoe定时拨号" >>/var/spool/cron/root
                    echo "*/$RNUM * * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1" >>/var/spool/cron/root
                    echo "#pppoe检测" >>/var/spool/cron/root
                    echo "*/2 * * * * $PATH_HOME/checkweibo.sh >>/mnt/checkpppoe.log 2>&1" >>/var/spool/cron/root
                    echo "#检测proxy以及pppoe" >>/var/spool/cron/root
                    echo "*/7 * * * * $PATH_HOME/checkproxy.sh >>/mnt/check.log 2>&1" >>/var/spool/cron/root
                    echo "#清空pppoecheck日志" >>/var/spool/cron/root
                    echo "0 18 * * * true >/mnt/checkpppoe.log" >>/var/spool/cron/root
                    echo "0 1 * * 6 true >/mnt/p.log" >>/var/spool/cron/root
                    echo "0 1 * * 6 true >/mnt/check.log" >>/var/spool/cron/root
                    echo "0 1 * * 1 true >/mnt/pppoe.log" >>/var/spool/cron/root
                    echo "#定时重启" >>/var/spool/cron/root
                    echo "10 8 * * * /sbin/reboot" >>/var/spool/cron/root
                    elif [ $1 -eq 1 ];then
                    if [ $3 -eq 0 ];then
                    echo "#pppoe定时拨号" >>/var/spool/cron/root
                    echo "*/$2 * * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1" >>/var/spool/cron/root
                    else 
                    echo "#pppoe定时拨号" >>/var/spool/cron/root
                    echo "$2 */$3 * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1" >>/var/spool/cron/root
                    fi
                    echo "#pppoe检测" >>/var/spool/cron/root
                    echo "*/2 * * * * $PATH_HOME/checkwx.sh >>/mnt/checkpppoe.log 2>&1" >>/var/spool/cron/root
                    echo "#检测proxy以及pppoe" >>/var/spool/cron/root
                    echo "*/7 * * * * $PATH_HOME/checkproxy.sh >>/mnt/check.log 2>&1" >>/var/spool/cron/root
                    echo "#清空pppoecheck日志" >>/var/spool/cron/root
                    echo "0 18 * * * true >/mnt/checkpppoe.log" >>/var/spool/cron/root
                    echo "0 1 * * 6 true >/mnt/p.log" >>/var/spool/cron/root
                    echo "0 1 * * 6 true >/mnt/check.log" >>/var/spool/cron/root
                    echo "0 1 * * 1 true >/mnt/pppoe.log" >>/var/spool/cron/root
                    echo "#定时重启" >>/var/spool/cron/root
                    echo "40 8 * * * /sbin/reboot" >>/var/spool/cron/root
                fi
fi