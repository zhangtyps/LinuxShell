#!/bin/bash
#-------------CopyRight-------------   
#   Name:Proxy Software automatic check squid status script   
#   Version Number:2.0   
#   Type:work   
#   Language:bash shell   
#   Date:2017-12-15  
#   Author:Baiqi  
#   Announcement ： No
# --------------check squid-----------
source /etc/profile
netstat -ntpl |grep squid |grep -v grep
if [ $? -eq 0 ];then
	echo "squid service is running"
else
	echo "squid  service is not running,start it"
	if [ $sysversion = 6 ];then
		service squid start
	else
		/bin/systemctl start  squid.service
	fi
	ps aux |grep squid |grep -v grep
	if [ $? -eq 0 ];then
		echo "squid service start success"
	else
		echo "squid service start failed,start it again!"
		/etc/rc.d/init.d/squid start
		ps aux |grep squid |grep -v grep
	fi
fi
#--------------Variable---------------
Pppoesh_dir=`find / -name pppoe.sh`
Dir_pppoe=`find /usr/*  -name pppoe`
Start_pppoe=${Dir_pppoe}-start
Stop_pppoe=${Dir_pppoe}-stop
#-------------check system -----------
#确定系统版本
systemctl status crond.service
if [ $? -eq 0 ];then
	echo "system version  7"
	sysversion=7
else
	echo  "system version 6"
	sysversion=6
fi
#--------------Running----------------
Pppoe_status=`cat /mnt/count.txt`
if [ $Pppoe_status -eq 0 ];then
	echo "dailing,wait please"
	sleep 60s
fi
Status=`curl --connect-timeout 10 -s -w "%{http_code}" "www.baidu.com" -o /dev/null`
if [ $Status -eq 200 ];then
	echo "Internet is ok"
	echo  "pppoe is running"
else
 	echo "Internet is bad,check pppoe first"
 	ps aux |grep pppoe-connect |grep -v grep
 	if [ $? -eq 0 ];then 
 		echo  "pppoe is running "
 		ExtranetIp=`/sbin/ifconfig ppp0 |grep inet | awk '{print  $2}' |cut -d: -f2`
 		echo $ExtranetIp >/var/log/c.log
 		cat /var/log/c.log |grep "Device not found"
	 	if [ $? -eq 0 ];then
	 		echo  "pppoe is ok,but internet is bad,reboot system now!"
	 		reboot
	 	else
	 		echo  "pppoe is bad,restart pppoe"
		 	$Pppoesh_dir
		 fi
	else
		echo  "pppoe is not running"
		$Pppoesh_dir
	fi
fi 

