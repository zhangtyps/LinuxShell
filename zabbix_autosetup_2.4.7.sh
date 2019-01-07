#!/bin/bash
#zabbix2.4.7自动安装脚本
#2019-1-7修改版

SETUP_PATH="/mnt/zabbix-2.4.7.tar.gz"
LOCAL_IP=`hostname -i`
SERVER_IP=10.51.18.252
#fileServer=10.162.53.136
#检测zabbix是否运行
ps aux |grep zabbix |grep -v grep > /dev/null
if [ $? -eq 1 ]; then
        echo "未检测到运行的zabbix程序------ "
        #如果zabbix安装包不存在，则拷贝
        # if [ ! -f  "$SETUP_PATH" ];then
        #         echo "本地/mnt目录下未检测到zabbix安装包，现在开始准备从vpn服务器拷贝zabbix安装包，请稍等------"
        #         scp -P 52198 xtyunweicpcc@"$fileServer":/opt/zabbix-2.4.7.tar.gz /mnt/
        #         if [ $? -eq 0 ];then
        #                 echo "zabbix文件复制成功"
        #         else
        #                 echo "zabbix文件复制失败，请检查网络是否畅通！"
        #                 exit 1
        #         fi
        # fi
        if [ -f "$SETUP_PATH" ];then
                #开始解压安装zabbix
                echo "找到zabbix安装文件，5秒后开始自动安装"
                sleep 5s
                cd /mnt/
                tar zxvf zabbix-2.4.7.tar.gz
                cd zabbix-2.4.7
                groupadd zabbix
		useradd -g zabbix -s /bin/nologin -M zabbix
                ./configure --prefix=/usr/local/zabbix --enable-agent
                make
                make install
		if [ $? -eq 0 ];then
			echo "zabbix编译安装成功，开始修改配置文件---"
                	#辅助相关文件配置
               		ln -s /usr/local/zabbix/sbin/* /usr/local/sbin/
                	ln -s /usr/local/zabbix/bin/* /usr/local/bin/
                	echo 'zabbix-agent 10050/tcp #Zabbix Agent' >> /etc/services
                	echo 'zabbix-agent 10050/udp #Zabbix Agent' >> /etc/services
                	echo 'zabbix-trapper 10051/tcp #Zabbix trapper' >> /etc/services
                	echo 'zabbix-trapper 10051/udp #Zabbix trapper' >> /etc/services
               		 #开始修改zabbix主配置文件
                	echo 'Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/' >> /usr/local/zabbix/etc/zabbix_agentd.conf
                	echo 'UnsafeUserParameters=1' >> /usr/local/zabbix/etc/zabbix_agentd.conf
                	#echo "ListenIP=$LOCAL_IP" >> /usr/local/zabbix/etc/zabbix_agentd.conf
                	sed -i "s/Server=.*/Server=$SERVER_IP/g" /usr/local/zabbix/etc/zabbix_agentd.conf
                	sed -i "s/ServerActive=.*/ServerActive=$SERVER_IP/g" /usr/local/zabbix/etc/zabbix_agentd.conf
                	sed -i "s/Hostname=.*/Hostname=$LOCAL_IP/g" /usr/local/zabbix/etc/zabbix_agentd.conf
               		 #开机启动配置
                	cp /mnt/zabbix-2.4.7/misc/init.d/fedora/core5/zabbix_agentd /etc/rc.d/init.d/zabbix_agentd
                	sed -i 's#ZABBIX_BIN="/usr/local/sbin/zabbix_agentd "#ZABBIX_BIN="/usr/local/zabbix/sbin/zabbix_agentd"#' /etc/rc.d/init.d/zabbix_agentd
                	chmod 744 /etc/rc.d/init.d/zabbix_agentd
                	chkconfig zabbix_agentd on
                	service zabbix_agentd start
                	sleep 3s
                	ps aux |grep zabbix |grep -v grep > /dev/null
              		if [ $? -eq 0 ]; then
                        	netstat -ntpl | grep zabbix_agentd
                        	echo "zabbix安装已完成"
                	else
                        	echo "zabbix已安装，但配置存在问题，请手动检查原因"
                        	exit 1
                	fi
		else
			echo "编译安装失败，请重新编译安装！"
			exit 1
        	fi
	else
		echo "未找到安装文件，脚本退出！"
		exit 0
	fi
else
        netstat -ntpl |grep zabbix_agentd
        echo "zabbix监控已安装！"
        exit 1
fi
