#!/bin/bash
#访问我的GitHub获得最新的代码：https://github.com/zhangtyps
#本脚本通过循环遍历数组，检查各个yii任务的执行情况，如果检测任务不存在，则进行重启并记录重启时间点
#ver1.1 支持比较奇葩带有/的yii任务

source /etc/profile
#保存原来的IFS的值
IFS_OLD=$IFS
#修改IFS分隔符为\n
#原来的分隔符因包含空格，会导致每个数组元素的yii命令按空格分割，直接导致后续执行报错
IFS=$'\n'

echo 
date "+%Y-%m-%d %H:%M:%S"
yiic="/usr/local/php/bin/php /data1/www/changan_dev/admin/protected/yiic"
task=()
task[1]="downdataForum Download"
task[2]="exportCsv downloadMoreScheme"
task[3]="exportCSV download --type=1 --sep=1"
task[4]="exportCSV download --type=1 --sep=2"
task[5]="exportCSV download --type=1 --sep=3"
task[6]="exportCSV download --type=1 --sep=4"
task[7]="exportCSV download --type=1 --sep=5"
task[8]="exportCSV download --type=1 --sep=6"
task[9]="exportCSV download --type=2 --sep=1"
task[10]="exportCSV download --type=2 --sep=2"
task[11]="schemeBriefdoc2 make"
task[12]="schemeCompare startSchemeCompare"
task[13]="yuqingReportMigrate make --type=1"
task[14]="yuqingReportMigrate make --type=2"
task[15]="yuqingReportMigrate make --type=3"
task[16]="scheme schemeAnalysisStop"
task[17]="schemeWarnInfoSend send --level=1"
task[18]="schemeWarnInfoSend send --level=2"
task[19]="downdataForum delDownload"

logdir="/var/log"
#循环检查数组中每个yii的执行情况
for cmd in ${task[@]}
do
    echo "[check task: $cmd]"
    ret=`ps -ef |grep "$cmd" | grep -v "grep" | wc -l`
    if [ "$ret" -ge "1" ]; then
    echo "runing ..."
    else
    echo "gone ... restart ..."
    filename=`echo $cmd | sed 's/ /_/g' | sed 's/\//_/g'`
    echo $filename
    _cmd="$yiic $cmd"
    echo $_cmd
    #临时恢复IFS的值
    #因为分隔符改成换行，shell会把一整行“nohup xxxx”一起当作了命令，所以就会一直报错。
    IFS=$IFS_OLD
    echo " " &>> $logdir/yiic.$filename.log
    echo "！检测到任务发生错误，错误时间为：" &>> $logdir/yiic.$filename.log
    echo `date "+%Y-%m-%d %H:%M:%S"` &>> $logdir/yiic.$filename.log
    nohup $_cmd &>> $logdir/yiic.$filename.log &
    fi
    #继续设置IFS的值为回车，不然会影响下一轮循环
    IFS=$'\n'
done