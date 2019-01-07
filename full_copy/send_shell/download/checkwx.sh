#!/bin/bash
#检测curl能否正确获得200/418返回值，如果错误将调用dail.sh或者pppoe.sh
#不带记录日志功能，记录日志请在计划任务内重定向记录
#如设置记录日志，需要清空日志定时任务"echo  >/mnt/my.log"
#COUNT为循环计数器
COUNT=0
MAXCOUNT=3
GETIPCOUNT=1
CHECKCOUNT=1
#NOTFIND=0
echo `date +'%Y-%m-%d %H:%M:%S'`
#进行循环3次检测，如果3轮检测都失败，则程序继续运行重启pppoe的代码部分
while [ $CHECKCOUNT -le $MAXCOUNT ]
do
    echo "正在进行第"$CHECKCOUNT"次检测中，请稍后"
    RESULT=`curl -o /dev/null --connect-timeout 10 -s -w %{http_code} https://mp.weixin.qq.com/s?__biz=MzAwNTA5NTYxOA==&mid=2650860746&idx=1&sn=9385a06569683c5a330ab79330c33f22&chksm=80d5a567b7a22c7177bbb39fdbc2cad35beb776ffb737277a6f5699b0a80676d13d15db42743&scene=0#rd` &>/dev/null
    if [ $RESULT -eq 200 ] || [ $RESULT -eq 418 ] || [ $RESULT -eq 403 ] || [ $RESULT -eq 301 ];then
        echo "PPPOE运行正常，http_code=$RESULT"
        exit 0 #退出程序
    else
        echo "http_code=$RESULT ，这可能是自动切换导致的，等待3秒后重新检测"
        sleep 3
    fi
    let CHECKCOUNT++
done

echo "3次检测均未通过，PPPOE错误：http_code=$RESULT，即将重启PPPOE..."
#获取该机器上pppoe重启脚本的位置
RESTARTSCRIPT=`find /home -name pppoe.sh`
if [ -z $RESTARTSCRIPT ];then
	RESTARTSCRIPT=`find /home -name dail.sh`
fi	
echo "即将运行的脚本路径为 $RESTARTSCRIPT"

#已获取机器上pppoe脚本的位置，将通过此脚本重启pppoe
while true
do
	if [ $COUNT -gt $MAXCOUNT ];then
		echo "超过最大循环次数，脚本已自动结束"
		exit 0
	fi
	#获得旧IP地址
	while true
	do
		if [ $GETIPCOUNT -ge $MAXCOUNT ];then
            echo "无法获取IP"
            OLDIP='0.0.0.0'
			break
		fi
		OLDIP=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
		if [ -z $OLDIP ];then
			echo "无法获取IP，可能是IP正在切换中，等待2秒后重新获取"
			sleep 2
		else
			break
		fi
        let GETIPCOUNT++
	done

    echo "正在结束pppoe进程……"
    KILLPPPOE=`find /usr/sbin  -name pppoe-stop`
    if [ -z $KILLPPPOE ];then
        KILLPPPOE=`find /usr/*  -name pppoe-stop`
    fi
    $KILLPPPOE &>/dev/null
    if [ $? -eq 0 ];then
        echo "pppoe进程结束成功"
    else
        echo "进程结束异常，将直接调用其他脚本"
    fi

    echo "当前IP为 $OLDIP ，开始调用pppoe.sh"
	#查看脚本运行日志，是否提示成功
    #echo   >/mnt/cp.log
	bash $RESTARTSCRIPT &> /mnt/cp.log
	let COUNT++
	cat /mnt/cp.log | grep "success" &>/dev/null
	if [ $? -eq 0 ];then
		NEWIP=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
		echo "新IP为 $NEWIP"
		if [[ $OLDIP != $NEWIP ]];then
			echo "IP切换/PPPOE重启成功，正在检测新IP:$NEWIP"
            CHECKCOUNT=1
            while [ $CHECKCOUNT -lt $MAXCOUNT ]
            do
                echo "正在检测新IP，当前循环:"$CHECKCOUNT
                RESULT3=`curl -o /dev/null --connect-timeout 10 -s -w %{http_code} https://mp.weixin.qq.com/s?__biz=MzAwNTA5NTYxOA==&mid=2650860746&idx=1&sn=9385a06569683c5a330ab79330c33f22&chksm=80d5a567b7a22c7177bbb39fdbc2cad35beb776ffb737277a6f5699b0a80676d13d15db42743&scene=0#rd` &>/dev/null
                if [ $RESULT3 -eq 200 ] || [ $RESULT3 -eq 418 ] || [ $RESULT3 -eq 403 ] || [ $RESULT3 -eq 301 ];then
                    echo "http_code=$RESULT3 ，IP可用"
				    exit 0
                else
                    echo "http_code=$RESULT3 ，等待3秒后重新检测"
                    sleep 3
                fi
                let CHECKCOUNT++
            done
		else
			echo "IP未改变，再次尝试运行脚本"
		fi
	else
		echo "pppoe.sh重启失败，正在重新运行调用pppoe.sh"
	fi
done



