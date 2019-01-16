#!/bin/bash
#清博会员管家专用，以后有时间改成服务器通用版
#访问我的GitHub获得最新版的脚本：https://github.com/zhangtyps/LinuxShell
#version 0.1

GET_SYSDISK_VALUE=`df -h / | sed -n 2p | awk '{print$5}' | grep -Eo '[0-9]+'`
if [ $GET_SYSDISK_VALUE -gt 80 ];then
    for i in `find /data1/www/member/logs/api/* -type f -size +1G`;
    do
        true >$i
        #find /data1/www/member/logs/api/* -type f -size +1G | xargs rm -rf
    done
fi
