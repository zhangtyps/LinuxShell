#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#version 2.0
#几乎重构了脚本，优化了脚本的写法，加入了严谨的参数判断，放弃了检测定时任务里的脚本是否存在的功能（因为没有意义）

#获取用户家目录路径（由于代理机上只有一个非root用户）此路径用于获取各个定时任务脚本的位置
PATH_HOME=`cat /etc/passwd | grep -v "/sbin/nologin" | grep "/home/" | sed -n 1p | cut -d: -f6`
#随机拨号时间范围（15-30,务必atime>btime）
ATIME=15
BTIME=30

#在这里修改（除定时拨号之外的）定时任务
function common_set() {
true >/var/spool/cron/root
cat >/var/spool/cron/root <<EOF
#远程管理执行命令
*/1 * * * * $PATH_HOME/run.sh >/dev/null 2>&1
#代理成功率和重复率统计
30 6 * * 5 $PATH_HOME/count.sh >/mnt/count.log 2>&1
30 6 * * 5 $PATH_HOME/countip.py >/mnt/countip.log 2>&1
#pppoe定时拨号
$PPPOE
#pppoe检测
*/2 * * * * $PATH_HOME/checkweibo.sh >>/mnt/checkpppoe.log 2>&1
#检测proxy以及pppoe
*/7 * * * * $PATH_HOME/checkproxy.sh >>/mnt/check.log 2>&1
#清空日志
0 18 * * * true >/mnt/checkpppoe.log
0 1 * * 6 true >/mnt/p.log
0 1 * * 6 true >/mnt/check.log
0 1 * * 1 true >/mnt/pppoe.log
#定时重启
10 8 * * * /sbin/reboot
EOF
}

#拨号通用
function normal_set() {
    #如果调用函数，参数1不存在，则设置为随机拨号的形式；若参数2也存在，则为自定义设置模式
    if [ -z $1 ];then
        PPPOE="*/$RNUM * * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1"
    elif [ -z $2 ] || [ $2 -eq 0 ];then
        if [ $1 -ge 0 ] && [ $1 -le 59 ];then
            PPPOE="*/$1 * * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1"
        else
            echo "定时任务时间参数错误，固定分钟范围在0-59之间"
            exit 0
        fi
    else
        if [ $1 -ge 0 ] && [ $1 -le 59 ] && [ $2 -ge 1 ] && [ $2 -le 23 ];then
            PPPOE="$1 */$2 * * * $PATH_HOME/pppoe.sh >>/mnt/p.log 2>&1"
        else
            echo "定时任务时间参数错误，固定分钟范围在0-59之间，每小时范围在1-23之间"
            exit 0
        fi
    fi
    common_set
}

#curl拨号方式
function curl_mode() {
    if [ -z $1 ];then
        $1=30 #这一步判断可有可无，因为在函数调用前已经做判断了，如果没有接收到参数，则设定curl请求时间为30秒
    fi
    #追加额外curl的定时任务
    echo "#检测curl脚本是否正常运行" >>/var/spool/cron/root
	echo "*/1 * * * * $PATH_HOME/loop_check.sh $1 $HOSTNAME >/var/log/loop_check.log 2>&1" >>/var/spool/cron/root
}

#main
RNUM=`shuf -i $ATIME-$BTIME -n 1`
#参数1为help时，输出帮助信息
if [ "$1" == "-h" ];then
cat <<EOF
脚本使用说明：（参数解释起来太麻烦了，直接看示例）
    ./crontab.sh                    随机时间（15-30）拨号，不使用curl
    ./crontab.sh 20                 每20分钟拨号，不使用curl
    ./crontab.sh 0 2                每2小时拨号，不使用curl
    ./crontab.sh curl 30            随机时间（15-30）拨号，curl 30秒请求一次
    ./crontab.sh 30 curl 50         每30分钟拨号，curl 50秒请求一次
    ./crontab.sh 0 3 curl 30        每3小时拨号，curl 30秒请求一次
EOF
exit 0
else
    #包含参数则判断参数，然后调用对应的函数
    if [ -z $1 ];then
        #随机时间拨号
        normal_set
    else
        if [ "$1" == "curl" ] || [ "$2" == "curl" ] || [ "$3" == "curl" ] ;then
            if [ "$1" == "curl" ] && [ $2 -gt 0 ];then
                normal_set
                curl_mode $2
            elif [ "$2" == "curl" ] && [ $3 -gt 0 ];then
                normal_set $1
                curl_mode $3
            elif [ "$3" == "curl" ] && [ $4 -gt 0 ];then
                normal_set $1 $2
                curl_mode $4
            else
                echo "参数输入有误，输入crontab.sh -h查看帮助信息"
            fi
        else
            normal_set $1 $2
        fi
    fi
fi