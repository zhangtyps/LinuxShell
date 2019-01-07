#!/bin/bash
#定时自动拨号切换ip
source /etc/profile
Dir_pppoe=`find /usr/*  -name pppoe`
Start_pppoe=${Dir_pppoe}-start
Stop_pppoe=${Dir_pppoe}-stop
echo "0">/mnt/count.txt
/usr/sbin/pppoe-stop
if [ $? -eq 0 ];then
        sleep 15	
        /usr/sbin/pppoe-start
else
        `$Stop_pppoe`
         sleep 15
        `$Start_pppoe`
fi
ExtranetIp=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2`
Status=`curl --connect-timeout 10 -s -w "%{http_code}" "www.baidu.com" -o /dev/null`
if [ $Status -eq 200 ];then
        echo "Dialing success,External network IP is  "$ExtranetIp
        edate=`date -d today +"%Y-%m-%d %T"`
        echo $edate" ""IP:"$ExtranetIp >>/mnt/pppoe.log
	oldip=`tail -n 2 /mnt/pppoe.log | head -n 1 | awk '{print$3}'| cut -d: -f2`
	curl -s "http://sdsdwesdfsdfsdfa.gstai.com:8081/$HOSTNAME:$oldip"
else
        echo "Dialing failure!"
fi

echo "1">/mnt/count.txt
