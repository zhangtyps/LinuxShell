#!/bin/bash
:<<INFO
@File : ban_cron.sh
@Time : 2019/02/27 10:41:31
@Author : 修改于zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.1
@Desc : 替换crontab命令，禁止使用-r参数，每次修改后自动备份定时任务，删除的旧备份
INFO

# 使用方法：
# 1.部署脚本，请给此脚本777的权限，否则普通用户无法使用crontab命令（切记！）
# 2.在/etc/bashrc中加入这么一行，路径请根据脚本位置自行修改（一定要放在普通用户有r-w权限的目录下，原因同第一条）
#   alias crontab='/mnt/ban_cron.sh'
# 3.执行source /etc/bashrc使之生效即可
# ps:测试请先用crontab -e看看是否有备份，再测试crontab -r命令

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