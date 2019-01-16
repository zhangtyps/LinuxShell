#!/bin/bash
true >/var/spool/cron/root
if [ -z $1 ];then
echo "未输入参数，0=公共，1=正文"
exit 0
fi

#参数检测
if [ $1 -eq 0 ];then
    if [ -z $2 ]||[ $2 -lt 0 ];then
    echo "未输入公共curl拨号时间或输入错误的数值，请重新输入"
    echo "参考格式：10秒请求一次，则输入./url_crontab.sh 0 10"
    echo "参考格式：1分钟请求一次，则输入./url_crontab.sh 0 60"
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
FIND5=`ls $PATH_HOME/curl.sh` &>/dev/null

if [ -z $FIND1 ] && [ -z $FIND2 ] && [ -z $FIND3 ] && [ -z $FIND4 ] && [ -z $FIND5 ];then          
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
		    echo "#检测curl脚本是否正常运行" >>/var/spool/cron/root
		    echo "*/1 * * * * $PATH_HOME/loop_check.sh $2 $HOSTNAME >/var/log/loop_check.log 2>&1" >>/var/spool/cron/root
                    elif [ $1 -eq 1 ];then
                    echo "#pppoe定时拨号" >>/var/spool/cron/root
                    echo "0 */2 * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1" >>/var/spool/cron/root
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
                    echo "40 8 * * 1,4 /sbin/reboot" >>/var/spool/cron/root
                fi
fi