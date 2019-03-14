#!/bin/bash
:<<INFO
@File : ban_cron.sh
@Time : 2019/02/27 10:41:31
@Author : 修改于zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.0
@Desc : 替换crontab命令，禁止使用-r参数，每次修改后自动备份定时任务，删除的旧备份
INFO

#使用方法：
#在/etc/bashrc中加入这么一行，路径请根据脚本位置自行修改
#alias crontab='/root/ban_cron.sh'
#然后执行source /etc/bashrc使之生效即可，测试请先用crontab -e看看是否有备份，再测试crontab -r命令

source /etc/profile;
source ~/.bash_profile;

etime=`date -d "0 days ago" +%Y%m%d_%H%M%S`

if [ "$1" = "-r" ] ; then
    echo "此参数被禁止使用！"
    exit 2
fi

if [ "$1" = "-l" ] ; then
    /usr/bin/crontab -l
    exit 0
fi

if [ "$1" = "-e" ] ; then
    mkdir -p  ~/cronbak
    /usr/bin/crontab -l  >  ~/cronbak/cron.bak.$etime.a
    /usr/bin/crontab -e
    /usr/bin/crontab -l  >  ~/cronbak/cron.bak.$etime.b
    find ~/cronbak/* -type f -mtime +30 -name 'cron.bak.*' | xargs rm -rf
fi