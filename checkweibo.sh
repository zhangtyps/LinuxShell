#!/bin/bash
#检测curl能否正确获得200/418返回值，如果错误将调用dail.sh或者pppoe.sh
COUNT=1
MAXCOUNT=3
CHECKCOUNT=1
#检测此脚本是否在执行
cat /mnt/cp_status.log | grep 1 &>/dev/null
if [ $? -eq 0 ];then
    ModifyTime=`stat -c %Y /mnt/cp_status.log`
    NowTime=`date +%s`
    CheckTime=`cat /var/spool/cron/root | grep $0 | cut -b 3`
    if [ $[ $NowTime - $ModifyTime ] -gt $[ $CheckTime * 60 + 10 ] ];then
        echo "***此脚本疑似卡住，下一个脚本将正常运行***"
    else
        exit 0 #退出程序
    fi
fi
#脚本执行，将文件中状态值改为1
echo 1 >/mnt/cp_status.log

#开始运行脚本
echo " "
echo `date +'%Y-%m-%d %H:%M:%S'`

#进行循环3次检测，如果3轮检测都失败，则程序继续运行重启pppoe的代码部分
while [ $CHECKCOUNT -le $MAXCOUNT ]
do
    echo "第"$CHECKCOUNT"次检测中……"
    RESULT=`curl -o /dev/null --connect-timeout 10 -s -w %{http_code} "https://api.weibo.cn/2/guest/cardlist?networktype=wifi&extparam=filter_type%3Drealtimehot&uicode=10000003&moduleID=708&checktoken=d2f0e8239fab76972c60b5aa85e2cf94&featurecode=10000085&wb_version=3731&c=android&i=a4dd36d&s=72b77166&ft=0&ua=Meizu-m3__weibo__8.8.2__android__android5.1&wm=9848_0009&aid=01AtwC0efp5LCBDUXfnW0jV5xH0y4eYi80zum2DeF6vBuwBVk.&did=4291753e18dd4bb4f45d2a2aca3560edbd873c37&fid=100103type%3D1%26q%3D%E5%82%85%E6%81%92%26t%3D0&lat=31.81651&lon=117.22844&uid=1008964766365&v_f=2&v_p=63&from=1088295010&gsid=_2AkMu6HqQf8NhqwJRmPAcym_laot0zA3EieKYtItLJRMxHRl-wT9jqmgmtRVKXCwbWFD-NjQnFsk1YIcbelDYMQ..&imsi=460037991152559&lang=zh_CN&lfid=100103type%3D1%26t%3D3&page=1&skin=default&count=10&oldwm=4209_8001&sflag=1&containerid=100103type%3D1%26q%3D%E5%82%85%E6%81%92%26t%3D0&ignore_inturrpted_error=true&luicode=10000003&container_ext=newhistory%3A0%7Cnettype%3Awifi%7Cshow_topic%3A1%7Cgps_timestamp%3A1534901178088&need_head_cards=1&cum=4E65E234"` &>/dev/null
    if [ $RESULT -eq 000 ];then
        echo "HTTP $RESULT"
        sleep 5
    elif [ $RESULT -eq 418 ] || [ $RESULT -eq 403 ];then
        echo "HTTP $RESULT"
        break
    else
        echo "HTTP $RESULT ，脚本已退出"
        echo 0 >/mnt/cp_status.log
        exit 0 #退出程序
    fi
    let CHECKCOUNT++
done

if [ $CHECKCOUNT -ne 1 ];then
    echo "【PPPOE错误或当前IP不可用，HTTP $RESULT ，即将重启PPPOE……】"
fi    

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
		echo "【超过最大循环次数，脚本已自动结束】"
        echo 0 >/mnt/cp_status.log
		exit 0
	fi
    
	#获得旧IP地址
	OLDIP=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
	if [ -z $OLDIP ];then
		OLDIP=`/sbin/ifconfig ppp1 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
	fi
    if [ -z $OLDIP ];then
        OLDIP='0.0.0.0'
		echo "未获取到当前IP"
	fi

	#echo "--正在结束pppoe进程……"
    KILLPPPOE=`find /usr/sbin  -name pppoe-stop`
    if [ -z $KILLPPPOE ];then
        KILLPPPOE=`find /usr/*  -name pppoe-stop`
    fi
    $KILLPPPOE &>/dev/null
    if [ $? -eq 0 ];then
        echo "--pppoe进程结束成功"
    else
        echo "--进程结束异常，将直接调用其他脚本"
    fi

	echo "【开始调用pppoe.sh/dail.sh】"
	#查看脚本运行日志，是否提示成功
	bash $RESTARTSCRIPT &> /mnt/cp.log
	let COUNT++ #循环计数器
	cat /mnt/cp.log | grep "success" &>/dev/null
	if [ $? -eq 0 ];then
		NEWIP=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
        if [ -z $NEWIP ];then
		    NEWIP=`/sbin/ifconfig ppp1 |grep inet | awk '{print  $2}' |cut -d: -f2` &>/dev/null
	    fi
        if [ -z $NEWIP ];then
            NEWIP='1.1.1.1'
		    echo "新IP获取失败，将直接进行检测"
	    fi
		#echo "新IP为 $NEWIP"
		if [[ $OLDIP != $NEWIP ]];then
			echo "IP切换成功，正在检测新IP:$NEWIP"
            CHECKCOUNT=1
            while [ $CHECKCOUNT -lt $MAXCOUNT ]
            do
                echo "正在检测新IP，当前循环:"$CHECKCOUNT
                RESULT3=`curl -o /dev/null --connect-timeout 10 -s -w %{http_code} "https://api.weibo.cn/2/guest/cardlist?networktype=wifi&extparam=filter_type%3Drealtimehot&uicode=10000003&moduleID=708&checktoken=d2f0e8239fab76972c60b5aa85e2cf94&featurecode=10000085&wb_version=3731&c=android&i=a4dd36d&s=72b77166&ft=0&ua=Meizu-m3__weibo__8.8.2__android__android5.1&wm=9848_0009&aid=01AtwC0efp5LCBDUXfnW0jV5xH0y4eYi80zum2DeF6vBuwBVk.&did=4291753e18dd4bb4f45d2a2aca3560edbd873c37&fid=100103type%3D1%26q%3D%E5%82%85%E6%81%92%26t%3D0&lat=31.81651&lon=117.22844&uid=1008964766365&v_f=2&v_p=63&from=1088295010&gsid=_2AkMu6HqQf8NhqwJRmPAcym_laot0zA3EieKYtItLJRMxHRl-wT9jqmgmtRVKXCwbWFD-NjQnFsk1YIcbelDYMQ..&imsi=460037991152559&lang=zh_CN&lfid=100103type%3D1%26t%3D3&page=1&skin=default&count=10&oldwm=4209_8001&sflag=1&containerid=100103type%3D1%26q%3D%E5%82%85%E6%81%92%26t%3D0&ignore_inturrpted_error=true&luicode=10000003&container_ext=newhistory%3A0%7Cnettype%3Awifi%7Cshow_topic%3A1%7Cgps_timestamp%3A1534901178088&need_head_cards=1&cum=4E65E234"` &>/dev/null
                if [ $RESULT3 -eq 000 ];then
                    echo "HTTP $RESULT3 ，等待5秒后重新检测"
                    sleep 5
                elif [ $RESULT3 -eq 418 ] || [ $RESULT3 -eq 403 ];then
                    echo "HTTP $RESULT3 ，此IP不可用"
                    break
                else
                    echo "HTTP $RESULT3 ，IP可用，脚本退出"
                    echo 0 >/mnt/cp_status.log
				    exit 0 
                fi
                let CHECKCOUNT++
            done
		else
			echo "IP未改变，再次尝试运行脚本"
		fi
	else
		echo "【调用脚本重启失败，正在重新调用】"
	fi
done

